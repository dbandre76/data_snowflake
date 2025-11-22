CREATE OR REPLACE PROCEDURE gold_dim_calendar()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$

BEGIN


create or replace table  gold_dim_calendar as 
with date_range as (
SELECT DATEADD(DAY, SEQ4(), (select min(order_date) from silver_orders)) AS date_key

FROM TABLE(GENERATOR(ROWCOUNT=>10000))
)
 SELECT 
    ROW_NUMBER() OVER (ORDER BY date_key) as date_sk, 
    date_key,
    YEAR(date_key) as year,
    QUARTER(date_key) as quarter,
    month(date_key) as month,
    day(date_key) as day,
     MONTHNAME(date_key) as month_name,
    DAYNAME(date_key) as day_name,
    WEEKOFYEAR(date_key) as week_number,
    IFF(DAYNAME(date_key) IN ('Sat', 'Sun'), true, false) as is_weekend
    from date_range

;

Return 'Dimensão de Calendário gerada';

END 
$$;