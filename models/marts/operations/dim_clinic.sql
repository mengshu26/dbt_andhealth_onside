
select distinct
    
    clinic_name,
    region,
    timezone,
    first_open_date,
    capacity_per_day

from {{ ref('int_clinic_base') }}


