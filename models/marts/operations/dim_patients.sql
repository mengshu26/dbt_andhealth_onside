

with visit_dates as (
    select
        patient_id,
        min(visit_date) as first_visit_date,
        max(visit_date) as last_visit_date
    from {{ ref('stg_visits') }}
    group by patient_id
),

visits_last_3_months as (
    select
        patient_id,
        count(*) as num_visits_last_3_months
    from {{ ref('stg_visits') }}
    where visit_date >= dateadd('month', -3, current_date())
    group by patient_id
),

quarterly_visits as (
    select
        v.patient_id,
        d.quarter,
        d.year,
        count(*) as visit_count
    from {{ ref('stg_visits') }} v
    join {{ ref('stg_date_dim') }} d on v.visit_date = d.date
    where d.year = extract(year from current_date())
    group by v.patient_id, d.quarter, d.year
),

quarterly_visit_pivot as (
    select
        patient_id,
        coalesce(max(case when quarter = 'Q1' then visit_count end), 0) as visits_q1,
        coalesce(max(case when quarter = 'Q2' then visit_count end), 0) as visits_q2,
        coalesce(max(case when quarter = 'Q3' then visit_count end), 0) as visits_q3,
        coalesce(max(case when quarter = 'Q4' then visit_count end), 0) as visits_q4
    from quarterly_visits
    group by patient_id
)

select
    p.patient_id,
    p.age_group,
    p.payer_type,
    p.gender,
    p.city,
    p.state,
    vd.first_visit_date,
    vd.last_visit_date,
    coalesce(v3m.num_visits_last_3_months, 0) as num_visits_last_3_months,
    case 
        when coalesce(v3m.num_visits_last_3_months, 0) > 0 then true 
        else false 
    end as is_active_patient,
    coalesce(qvp.visits_q1, 0) as visits_q1,
    coalesce(qvp.visits_q2, 0) as visits_q2,
    coalesce(qvp.visits_q3, 0) as visits_q3,
    coalesce(qvp.visits_q4, 0) as visits_q4
from {{ ref('stg_patients') }} p
left join visit_dates vd
    on p.patient_id = vd.patient_id
left join visits_last_3_months v3m
    on p.patient_id = v3m.patient_id
left join quarterly_visit_pivot qvp
    on p.patient_id = qvp.patient_id