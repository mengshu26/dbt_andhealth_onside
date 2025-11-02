
with source as (

    select * from {{ source('source', 'providers') }}

),

renamed as (

    select
        cast(provider_id as varchar) as provider_id,
        cast(provider_name as varchar) as provider_name,
        cast(provider_type as varchar) as provider_type,
        {{ clean_clinic_name('home_clinic') }} as home_clinic

    from source

)

select * from renamed

