select
    clinic_location as clinic_name,
    visit_date,
    count(*) as total_visits
from {{ ref('stg_visits') }}
where clinic_location is not null
group by 1,2;
