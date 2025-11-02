
with source as (

    select * from {{ source('source', 'patients') }}

),

renamed as (

    select
        cast(patient_id as varchar) as patient_id,
        cast(age_group as varchar) as age_group,
        cast(payer_type as varchar) as payer_type,
        cast(gender as varchar) as gender,
        cast(city as varchar) as city,
        cast(state as varchar) as state

    from source

)

select * from renamed

