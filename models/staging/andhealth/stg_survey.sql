
with source as (

    select * from {{ source('source', 'survey') }}

),

renamed as (

    select
        visit_id,
        satisfaction_score,
        comment_text

    from source

)

select * from renamed

