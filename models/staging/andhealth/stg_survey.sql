
with source as (

    select * from {{ source('source', 'survey') }}

),

renamed as (

    select
        cast(visit_id as varchar) as visit_id,
        cast(satisfaction_score as integer) as satisfaction_score,
        cast(comment_text as varchar) as comment_text

    from source

)

select * from renamed

