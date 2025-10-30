{{ config(
    materialized='table'
    ) }}

with primary_providers as (
    select
        visit_id,
        provider_id as primary_provider_id,
        role_in_visit
    from {{ ref('stg_visit_providers') }}
    where upper(role_in_visit) = 'PRIMARY'
),

secondary_providers as (
    select
        visit_id,
        provider_id as secondary_provider_id,
        role_in_visit
    from {{ ref('stg_visit_providers') }}
    where upper(role_in_visit) = 'SECONDARY'
)

select
    v.visit_id,
    v.appointment_id,
    v.patient_id,
    v.visit_date,
    v.billed_amount,
    v.clinic_location,
    v.is_first_visit_for_patient,
    v.visit_duration_minutes,
    v.modality,
    -- Primary Provider Information
    pp.primary_provider_id,
    pp_prov.provider_name as primary_provider_name,
    pp_prov.provider_type as primary_provider_type,
    pp_prov.home_clinic as primary_provider_home_clinic,
    -- Secondary Provider Information
    sp.secondary_provider_id,
    sp_prov.provider_name as secondary_provider_name,
    sp_prov.provider_type as secondary_provider_type,
    sp_prov.home_clinic as secondary_provider_home_clinic
from {{ ref('stg_visits') }} v
left join primary_providers pp
    on v.visit_id = pp.visit_id
left join {{ ref('stg_providers') }} pp_prov
    on pp.primary_provider_id = pp_prov.provider_id
left join secondary_providers sp
    on v.visit_id = sp.visit_id
left join {{ ref('stg_providers') }} sp_prov
    on sp.secondary_provider_id = sp_prov.provider_id


