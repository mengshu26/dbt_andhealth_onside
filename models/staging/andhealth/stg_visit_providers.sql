
with source as (

    select * from {{ source('source', 'visit_providers') }}

),

renamed as (

    select
        cast(visit_id as varchar) as visit_id,
        cast(provider_id as varchar) as provider_id,
        cast(role_in_visit as varchar) as role_in_visit

    from source

)

select * from renamed

