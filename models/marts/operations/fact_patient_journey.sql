with journey_events as (
    select
        patient_id,
        'appointment' as event_type,
        appointment_id as event_id,
        cast(scheduled_at as date) as event_date,
        clinic_location as clinic_name,
        provider_id,
        status as event_status
    from {{ ref('stg_appointments') }}

    union all

    select
        patient_id,
        'visit' as event_type,
        visit_id as event_id,
        visit_date as event_date,
        clinic_location as clinic_name,
        provider_id,
        null as event_status
    from {{ ref('stg_visits') }}

    union all

    select
        v.patient_id,
        'survey' as event_type,
        s.visit_id as event_id,
        null as event_date,  -- or link to visit for actual date?
        null as clinic_name,
        null as provider_id,
        null as event_status
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
)

select
    *,
    case when prior_event_date is not null and event_date is not null then datediff('day', prior_event_date, event_date) else null end as days_since_prior_event
from journey_with_lag
