CREATE OR REPLACE PROCEDURE gold_dim_calendar()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$

BEGIN


CREATE OR REPLACE TABLE gold_dim_calendar AS
WITH bounds AS (
    SELECT 
        MIN(order_date) AS min_date,
        MAX(order_date) AS max_date
    FROM silver_orders
),
dates AS (
    SELECT 
        DATEADD(
            day, 
            seq4(),
            b.min_date
        ) AS date_day
    FROM bounds b
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 10000)) g
    WHERE DATEADD(day, seq4(), b.min_date) <= b.max_date
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date_day) AS date_sk,
    date_day AS date_key,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    DAY(date_day) AS day,
    MONTHNAME(date_day) AS month_name,
    DAYNAME(date_day) AS day_name,
    WEEKOFYEAR(date_day) AS week_number,
    IFF(DAYNAME(date_day) IN ('Sat', 'Sun'), true, false) AS is_weekend
FROM dates
ORDER BY date_day

;

Return 'Load Gold Dim Calendar table successfully';

END 
$$;