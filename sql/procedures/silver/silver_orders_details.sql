CREATE OR REPLACE PROCEDURE load_silver_orders_details()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE silver_orders_details;

    INSERT INTO silver_orders_details
    SELECT
        $1:"order_id"::NUMBER     AS order_id,
        $1:"product_id"::NUMBER   AS product_id,
        $1:"unit_price"::FLOAT    AS unit_price,
        $1:"quantity"::NUMBER     AS quantity,
        $1:"discount"::FLOAT      AS discount,
        ($1:"quantity"::NUMBER * $1:"unit_price"::FLOAT) AS total
    from bronze_orders_details;

    RETURN 'Load Silver Orders Details table successfully';
END;
$$;