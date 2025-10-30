{% macro clean_clinic_name(clinic_column) %}
    case
        when upper(trim({{ clinic_column }})) in ('NORTHSIDE CLINIC', 'NORTH SIDE', 'NORTHSIDE') 
            then 'Northside Clinic'
        when upper(trim({{ clinic_column }})) in ('DOWNTOWN CLINIC', 'DOWNTOWN') 
            then 'Downtown Clinic'
        when upper(trim({{ clinic_column }})) in ('UPTOWN CLINIC', 'UPTOWN') 
            then 'Uptown Clinic'
        when upper(trim({{ clinic_column }})) in ('RIVERSIDE CLINIC', 'RIVERSIDE') 
            then 'Riverside Clinic'
        when upper(trim({{ clinic_column }})) in ('EAST CLINIC', 'EAST HEALTH CENTER', 'EAST CLINIC', 'EAST') 
            then 'East Clinic'
        when upper(trim({{ clinic_column }})) in ('SOUTH CLINIC', 'SOUTH') 
            then 'South Clinic'
        when upper(trim({{ clinic_column }})) in ('TELEHEALTH HUB') 
            then 'Telehealth Hub'
        else {{ clinic_column }} 
    end
{% endmacro %}


