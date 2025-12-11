
CREATE OR REPLACE PROCEDURE load_bronze_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE bronze_orders;

    INSERT INTO bronze_orders
SELECT 
    CAST($1 AS VARIANT) as raw,                   -- ← CAST para VARIANT
    metadata$filename as filename,                     
    CURRENT_TIMESTAMP() as created_at                  
FROM @POC.PUBLIC.NORTH/orders/orders (FILE_FORMAT => 'PARQUET_FORMAT');
    RETURN 'Load Bronze Orders table successfully';
END;
$$;