{% macro in_compile() %}
    {#
      True means callers should render empty SQL and skip metric side effects.
      dbt --empty keeps the constant in re_data_run_started_at, but rewrites
      ref() to `where false limit 0`, so data[0] does not exist.
    #}
    {% if not execute or flags.EMPTY %}
        {{ return(true) }}
    {% endif %}

    {%- call statement('in_compile', fetch_result=True) -%}
        select * from {{ ref('re_data_run_started_at') }}
    {%- endcall -%}

    {% set loaded = load_result('in_compile') %}
    {% set result_data = loaded['data'] if loaded else none %}
    {% if result_data is none or (result_data | length) == 0 %}
        {{ return(true) }}
    {% endif %}

    {% set result = result_data[0][0] %}
    {% if result == run_started_at.timestamp() * 1000000 %}
        {{ return(false) }}
    {% else %}
        {{ return(true) }}
    {% endif %}
{% endmacro %}
