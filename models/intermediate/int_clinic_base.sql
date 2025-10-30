with all_names as (
    select clean_clinic_name(home_clinic) as clinic_name from {{ ref('stg_providers') }} where home_clinic is not null
    union
    select clean_clinic_name(clinic_location) as clinic_name from {{ ref('stg_visits') }} where clinic_location is not null
    union
    select clean_clinic_name(clinic_location) as clinic_name from {{ ref('stg_appointments') }} where clinic_location is not null
)
select distinct
    clinic_name as clinic_name_clean,
    null as region,
    null as timezone,
    null as first_open_date
from all_names;

