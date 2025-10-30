
with source as (

    select * from {{ source('source', 'visit_providers') }}

),

renamed as (

    select
        visit_id,
        provider_id,
        role_in_visit

    from source

)

select * from renamed

