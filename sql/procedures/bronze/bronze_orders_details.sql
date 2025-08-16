-- Test Customer Table
CREATE OR REPLACE PROCEDURE load_bronze_orders_details()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE BRONZE_ORDERS_DETAILS;

    INSERT INTO bronze_orders_details
SELECT 
    CAST($1 AS VARIANT) as raw,                   -- ← CAST para VARIANT
    metadata$filename as filename,                     
    CURRENT_TIMESTAMP() as created_at                  
FROM @POC.PUBLIC.NORTH/orders_details (FILE_FORMAT => 'PARQUET_FORMAT');
    RETURN 'Load Bronze Customers table successfully';
END;
$$;