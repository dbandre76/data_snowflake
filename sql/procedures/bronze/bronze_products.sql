-- Test Customer Table
CREATE OR REPLACE PROCEDURE load_bronze_products()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE BRONZE_PRODUCTS;

    INSERT INTO bronze_products
SELECT 
    CAST($1 AS VARIANT) as raw,                   -- ← CAST para VARIANT
    metadata$filename as filename,                     
    CURRENT_TIMESTAMP() as created_at                  
FROM @POC.PUBLIC.NORTH/products (FILE_FORMAT => 'PARQUET_FORMAT');
    RETURN 'Load Bronze Customers table successfully';
END;
$$;