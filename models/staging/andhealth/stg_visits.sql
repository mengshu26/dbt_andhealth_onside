
with source as (

    select * from {{ source('source', 'visits') }}

),

renamed as (

    select
        visit_id,
        appointment_id,
        patient_id,
        visit_date,
        provider_id,
        billed_amount,
        {{ clean_clinic_name('clinic_location') }} as clinic_location,
        is_first_visit_for_patient,
        visit_duration_minutes,
        modality

    from source

)

select * from renamed

