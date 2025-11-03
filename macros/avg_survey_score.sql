{% macro avg_survey_score(survey_score_sum, survey_count, precision=2) %}
    round(sum({{ survey_score_sum }}) / nullif(sum({{ survey_count }}), 0), {{ precision }})
{% endmacro %}

