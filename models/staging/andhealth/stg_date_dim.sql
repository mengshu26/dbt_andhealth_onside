
with source as (

    select * from {{ source('source', 'date_dim') }}

),

renamed as (

    select
        date,
        month,
        quarter,
        year

    from source

)

select * from renamed

