CREATE OR REPLACE PROCEDURE load_silver_orders_details()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE SILVER_ORDERS_DETAILS;

    INSERT INTO SILVER_ORDERS_DETAILS
    SELECT
        $1:"order_id"::NUMBER     AS order_id,
        $1:"product_id"::NUMBER   AS product_id,
        $1:"unit_price"::FLOAT    AS unit_price,
        $1:"quantity"::NUMBER     AS quantity,
        $1:"discount"::FLOAT      AS discount,
        ($1:"quantity"::NUMBER * $1:"unit_price"::FLOAT) AS total
    FROM POC.PUBLIC.orders_details;

    RETURN 'Load Siver Orders Details table successfully';
END
$$;