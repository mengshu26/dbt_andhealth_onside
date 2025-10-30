
with visit_dates as (
    select
        provider_id,
        min(visit_date) as first_visit_date,
        max(visit_date) as last_visit_date
    from {{ ref('stg_visits') }}
    group by provider_id
),

visits_last_3_months as (
    select
        provider_id,
        count(*) as num_visits_last_3_months
    from {{ ref('stg_visits') }}
    where visit_date >= dateadd('month', -3, current_date())
    group by provider_id
),

quarterly_visits as (
    select
        v.provider_id,
        d.quarter,
        d.year,
        count(*) as visit_count
    from {{ ref('stg_visits') }} v
    join {{ ref('stg_date_dim') }} d on v.visit_date = d.date
    where d.year = extract(year from current_date())
    group by v.provider_id, d.quarter, d.year
),

quarterly_visit_pivot as (
    select
        provider_id,
        coalesce(max(case when quarter = 'Q1' then visit_count end), 0) as visits_q1,
        coalesce(max(case when quarter = 'Q2' then visit_count end), 0) as visits_q2,
        coalesce(max(case when quarter = 'Q3' then visit_count end), 0) as visits_q3,
        coalesce(max(case when quarter = 'Q4' then visit_count end), 0) as visits_q4
    from quarterly_visits
    group by provider_id
)

select
    p.provider_id,
    p.provider_name,
    p.provider_type,
    p.home_clinic,
    vd.first_visit_date,
    vd.last_visit_date,
    coalesce(v3m.num_visits_last_3_months, 0) as num_visits_last_3_months,
    case 
        when coalesce(v3m.num_visits_last_3_months, 0) > 0 then true 
        else false 
    end as is_active_provider,
    coalesce(qvp.visits_q1, 0) as visits_q1,
    coalesce(qvp.visits_q2, 0) as visits_q2,
    coalesce(qvp.visits_q3, 0) as visits_q3,
    coalesce(qvp.visits_q4, 0) as visits_q4
from {{ ref('stg_providers') }} p
left join visit_dates vd
    on p.provider_id = vd.provider_id
left join visits_last_3_months v3m
    on p.provider_id = v3m.provider_id
left join quarterly_visit_pivot qvp
    on p.provider_id = qvp.provider_id

