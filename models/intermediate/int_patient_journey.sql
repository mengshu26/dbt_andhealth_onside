with journey_events as (
    select
        patient_id,
        'appointment' as event_type,
        appointment_id as event_id,
        cast(scheduled_at as date) as event_date,
        clinic_location as clinic_name,
        provider_id,
        status as event_status,
        null as satisfaction_score
    from {{ ref('stg_appointments') }}

    union all

    select
        patient_id,
        'visit' as event_type,
        visit_id as event_id,
        visit_date as event_date,
        clinic_location as clinic_name,
        provider_id,
        null as event_status,
        null as satisfaction_score
    from {{ ref('stg_visits') }}

    union all

    select
        v.patient_id,
        'survey' as event_type,
        s.visit_id as event_id,
        v.visit_date as event_date, -- could use survey date instead of visit date if available 
        v.clinic_location as clinic_name,
        v.provider_id,
        null as event_status,
        s.satisfaction_score as satisfaction_score 
    from {{ ref('stg_survey') }} s
    left join {{ ref('stg_visits') }} v
        on s.visit_id = v.visit_id
),

journey_numbered as (
    select *,
        row_number() over (partition by patient_id order by event_date) as sequence_number
    from journey_events
),

journey_with_lag as (
    select *,
        lag(event_date) over (partition by patient_id order by event_date) as prior_event_date
    from journey_numbered
),

journey_with_metadata as (
    select
        *,
        case when prior_event_date is not null and event_date is not null then datediff('day', prior_event_date, event_date) else null end as days_since_prior_event,
        row_number() over (
            partition by patient_id 
            order by event_date desc, event_type
        ) as event_rank_reverse
    from journey_with_lag
)

select
    *,
    case 
        when event_rank_reverse = 1 
            and event_type = 'survey' 
            and satisfaction_score <= 2
        then true
        else false
    end as is_last_event_low_score_survey
from journey_with_metadata
