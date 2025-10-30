
with source as (

    select * from {{ source('source', 'appointments') }}

),

renamed as (

    select
        appointment_id,
        patient_id,
        scheduled_at,
        status,
        {{ clean_clinic_name('clinic_location') }} as clinic_location,
        provider_id

    from source

)

select * from renamed

