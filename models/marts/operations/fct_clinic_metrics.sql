with visits_q as (
  select
    v.clinic_name,
    d.year,
    d.quarter,
    sum(v.total_visits) as total_visits
  from {{ ref('int_clinic_visits_daily') }} v
  join {{ ref('stg_date_dim') }} d on v.visit_date = d.date
  group by 1,2,3
),
appointments_q as (
  select
    a.clinic_name,
    d.year,
    d.quarter,
    sum(a.total_appointments) as total_appointments,
    sum(a.cancelled) as cancelled,
    sum(a.rescheduled) as rescheduled,
    sum(a.no_show) as no_show,
    sum(a.completed) as completed
  from {{ ref('int_clinic_appointments_daily') }} a
  join {{ ref('stg_date_dim') }} d on a.scheduled_at = d.date
  group by 1,2,3
)
select
  coalesce(v.clinic_name, a.clinic_name) as clinic_name,
  coalesce(v.year, a.year) as year,
  coalesce(v.quarter, a.quarter) as quarter,
  coalesce(v.total_visits, 0) as total_visits,
  coalesce(a.total_appointments, 0) as total_appointments,
  coalesce(a.cancelled, 0) as cancelled,
  coalesce(a.rescheduled, 0) as rescheduled,
  coalesce(a.no_show, 0) as no_show,
  coalesce(a.completed, 0) as completed
from visits_q v
full outer join appointments_q a
  on v.clinic_name = a.clinic_name
  and v.year = a.year
  and v.quarter = a.quarter
