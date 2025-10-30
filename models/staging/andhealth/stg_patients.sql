
with source as (

    select * from {{ source('source', 'patients') }}

),

renamed as (

    select
        patient_id,
        age_group,
        payer_type,
        gender,
        city,
        state

    from source

)

select * from renamed

