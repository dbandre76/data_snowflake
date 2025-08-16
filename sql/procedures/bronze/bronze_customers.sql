-- Test Customer Table
CREATE OR REPLACE PROCEDURE load_bronze_customers()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE BRONZE_CUSTOMERS;

    INSERT INTO bronze_customers
SELECT 
    CAST($1 AS VARIANT) as raw,                   -- ← CAST para VARIANT
    metadata$filename as filename,                     
    CURRENT_TIMESTAMP() as created_at                  
FROM @POC.PUBLIC.NORTH/customers  (FILE_FORMAT => 'PARQUET_FORMAT');
    RETURN 'Load Bronze Customers table successfully';
END;
$$;