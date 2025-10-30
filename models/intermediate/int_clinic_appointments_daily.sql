select
    {{ clean_clinic_name('clinic_location') }} as clinic_name,
    scheduled_at,
    count(*) as total_appointments,
    sum(case when upper(status)='CANCELLED' then 1 else 0 end) as cancelled,
    sum(case when upper(status)='RESCHEDULED' then 1 else 0 end) as rescheduled,
    sum(case when upper(status)='NO_SHOW' then 1 else 0 end) as no_show,
    sum(case when upper(status)='COMPLETED' then 1 else 0 end) as completed
from {{ ref('stg_appointments') }}
where clinic_location is not null
group by 1,2
