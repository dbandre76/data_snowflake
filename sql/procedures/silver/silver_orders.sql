
CREATE OR REPLACE PROCEDURE load_silver_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE SILVER_ORDERS;

    INSERT INTO SILVER_ORDERS
    SELECT
        $1:"order_id"::NUMBER                AS order_id,
        UPPER($1:"customer_id"::STRING)      AS customer_id,
        $1:"employee_id"::NUMBER             AS employee_id,
        $1:"order_date"::TIMESTAMP_NTZ       AS order_date,
        $1:"required_date"::TIMESTAMP_NTZ    AS required_date,
        $1:"shipped_date"::TIMESTAMP_NTZ     AS shipped_date,
        $1:"ship_via"::NUMBER                AS ship_via,
        $1:"freight"::FLOAT                  AS freight,
        UPPER($1:"ship_name"::STRING)        AS ship_name,
        UPPER($1:"ship_address"::STRING)     AS ship_address,
        UPPER($1:"ship_city"::STRING)        AS ship_city,
        UPPER($1:"ship_postal_code"::STRING) AS ship_postal_code,
        UPPER($1:"ship_country"::STRING)     AS ship_country
    FROM POC.PUBLIC.orders;

    RETURN 'Load Siver Orders table successfully';
END;
$$;