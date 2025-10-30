
with source as (

    select * from {{ source('source', 'providers') }}

),

renamed as (

    select
        provider_id,
        provider_name,
        provider_type,
        {{ clean_clinic_name('home_clinic') }} as home_clinic

    from source

)

select * from renamed

