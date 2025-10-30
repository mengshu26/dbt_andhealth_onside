with appt_daily as (
    select
        provider_id,
        cast(scheduled_at as date) as date,
        clinic_location as clinic_name,
        count(*) as num_appointments,
        sum(case when upper(status) = 'COMPLETED' then 1 else 0 end) as num_appointments_completed,
        sum(case when upper(status) = 'NO_SHOW' then 1 else 0 end) as num_appointments_no_show,
        sum(case when upper(status) = 'CANCELLED' then 1 else 0 end) as num_appointments_cancelled,
        sum(case when upper(status) = 'RESCHEDULED' then 1 else 0 end) as num_appointments_rescheduled,
        count(distinct patient_id) as num_unique_patients_scheduled
    from {{ ref('stg_appointments') }}
    group by provider_id, clinic_location, cast(scheduled_at as date)
),

visits_daily as (
    select
        provider_id,
        visit_date as date,
        clinic_location as clinic_name,
        count(distinct visit_id) as num_visits,
        count(distinct patient_id) as num_unique_patients_seen
    from {{ ref('stg_visits') }}
    group by provider_id, clinic_location, visit_date
),

fact_provider_utilization as (
    select
        a.provider_id,
        coalesce(a.date, v.date) as date,
        coalesce(a.clinic_name, v.clinic_name) as clinic_name,
        coalesce(num_appointments, 0) as num_appointments,
        coalesce(num_appointments_completed, 0) as num_appointments_completed,
        coalesce(num_appointments_no_show, 0) as num_appointments_no_show,
        coalesce(num_appointments_cancelled, 0) as num_appointments_cancelled,
        coalesce(num_appointments_rescheduled, 0) as num_appointments_rescheduled,
        coalesce(a.num_unique_patients_scheduled, 0) as num_unique_patients_scheduled,
        coalesce(v.num_visits, 0) as num_visits,
        coalesce(v.num_unique_patients_seen, 0) as num_unique_patients_seen
    from appt_daily a
    full outer join visits_daily v
        on a.provider_id = v.provider_id
        and a.date = v.date
        and a.clinic_name = v.clinic_name
)

select * from fact_provider_utilization
