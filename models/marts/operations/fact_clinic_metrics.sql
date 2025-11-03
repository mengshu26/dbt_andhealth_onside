with visits_q as (
  select
    v.clinic_name,
    d.year,
    d.quarter,
    sum(v.total_visits) as total_visits,
    sum(v.telehealth_visits) as telehealth_visits
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
  join {{ ref('stg_date_dim') }} d on cast(a.scheduled_at as date) = d.date
  group by 1,2,3
),
survey_q as (
  select
    s.clinic_name,
    d.year,
    d.quarter,
    {{ avg_survey_score('s.survey_score_sum', 's.survey_count') }} as avg_survey_score,
    sum(s.survey_count) as survey_count,
    sum(s.survey_score_sum) as survey_score_sum,
    sum(s.survey_score_1_count) as survey_score_1_count,
    sum(s.survey_score_2_count) as survey_score_2_count,
    sum(s.survey_score_3_count) as survey_score_3_count,
    sum(s.survey_score_4_count) as survey_score_4_count,
    sum(s.survey_score_5_count) as survey_score_5_count
  from {{ ref('int_clinic_survey_daily') }} s
  join {{ ref('stg_date_dim') }} d on s.visit_date = d.date
  group by 1,2,3
)
select
  coalesce(v.clinic_name, a.clinic_name, s.clinic_name) as clinic_name,
  coalesce(v.year, a.year, s.year) as year,
  coalesce(v.quarter, a.quarter, s.quarter) as quarter,
  coalesce(v.total_visits, 0) as total_visits,
  coalesce(v.telehealth_visits, 0) as telehealth_visits,
  coalesce(a.total_appointments, 0) as total_appointments,
  coalesce(a.cancelled, 0) as cancelled,
  coalesce(a.rescheduled, 0) as rescheduled,
  coalesce(a.no_show, 0) as no_show,
  coalesce(a.completed, 0) as completed,
  coalesce(s.avg_survey_score, 0) as avg_survey_score,
  coalesce(s.survey_count, 0) as survey_count,
  coalesce(s.survey_score_sum, 0) as survey_score_sum,
  coalesce(s.survey_score_1_count, 0) as survey_score_1_count,
  coalesce(s.survey_score_2_count, 0) as survey_score_2_count,
  coalesce(s.survey_score_3_count, 0) as survey_score_3_count,
  coalesce(s.survey_score_4_count, 0) as survey_score_4_count,
  coalesce(s.survey_score_5_count, 0) as survey_score_5_count
from visits_q v
full outer join appointments_q a
  on v.clinic_name = a.clinic_name
  and v.year = a.year
  and v.quarter = a.quarter
full outer join survey_q s
  on coalesce(v.clinic_name, a.clinic_name) = s.clinic_name
  and coalesce(v.year, a.year) = s.year
  and coalesce(v.quarter, a.quarter) = s.quarter
