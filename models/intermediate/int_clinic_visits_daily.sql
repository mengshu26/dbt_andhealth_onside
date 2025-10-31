select
    clinic_location as clinic_name,
    visit_date,
    count(*) as total_visits,
    sum(case when upper(modality) = 'TELEHEALTH' then 1 else 0 end) as telehealth_visits
from {{ ref('stg_visits') }}
where clinic_location is not null
group by 1,2
