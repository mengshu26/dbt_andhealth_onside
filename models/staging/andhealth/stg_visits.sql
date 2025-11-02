with source as (

  select * from {{ source('source','visits') }}

),

renamed as (

  select

    cast(visit_id as varchar) as visit_id,
    cast(appointment_id as varchar) as appointment_id,
    cast(patient_id as varchar) as patient_id,
    cast(visit_date as date) as visit_date,
    cast(provider_id as varchar) as provider_id,
    cast(billed_amount as number) as billed_amount,
    {{ clean_clinic_name('clinic_location') }} as clinic_location,
    cast(is_first_visit_for_patient as boolean) as is_first_visit_for_patient,
    cast(visit_duration_minutes as number) as visit_duration_minutes,
    lower(trim(modality)) as modality

  from source
)

select

  *,
  case when clinic_location like '%telehealth%' or modality = 'telehealth' then 1 else 0 end as is_telehealth
  
from renamed
