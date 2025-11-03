with surveys as (
  select
    v.clinic_location as clinic_name,
    v.visit_date,
    cast(s.satisfaction_score as integer) as satisfaction_score,
    s.visit_id
  from {{ ref('stg_survey') }} s
  join {{ ref('stg_visits') }} v on s.visit_id = v.visit_id
  where v.clinic_location is not null
)

select
    clinic_name,
    visit_date,
    count(*) as survey_count,
    sum(satisfaction_score) as survey_score_sum,
    sum(satisfaction_score) / count(*) as avg_satisfaction_score,
    sum(case when satisfaction_score = 1 then 1 else 0 end) as survey_score_1_count,
    sum(case when satisfaction_score = 2 then 1 else 0 end) as survey_score_2_count,
    sum(case when satisfaction_score = 3 then 1 else 0 end) as survey_score_3_count,
    sum(case when satisfaction_score = 4 then 1 else 0 end) as survey_score_4_count,
    sum(case when satisfaction_score = 5 then 1 else 0 end) as survey_score_5_count
from surveys
group by 1,2


