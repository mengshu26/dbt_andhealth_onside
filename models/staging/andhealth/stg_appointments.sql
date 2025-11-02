with source as (

  select * from {{ source('source','appointments') }}

),

renamed as (

  select
    cast(appointment_id as varchar) as appointment_id,
    cast(patient_id as varchar) as patient_id,
    cast(scheduled_at as timestamp_ntz) as scheduled_at,
    cast(status as varchar) as status,
    {{ clean_clinic_name('clinic_location') }} as clinic_location,
    cast(provider_id as varchar) as provider_id
  from source

)

select

  *,
  cast(scheduled_at as date) as scheduled_date,
  case when status ilike 'rescheduled' then 1 else 0 end as is_rescheduled_row

from renamed

 
