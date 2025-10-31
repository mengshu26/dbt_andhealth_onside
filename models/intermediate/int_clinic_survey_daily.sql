with surveys as (
  select
    v.clinic_location as clinic_name,
    v.visit_date,
    try_to_number(s.satisfaction_score) as satisfaction_score,
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
    sum(satisfaction_score) / count(*) as avg_satisfaction_score
from surveys
group by 1,2


