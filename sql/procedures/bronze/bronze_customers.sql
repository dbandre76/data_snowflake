-- Procedure Bronze Customers com controle de erro
CREATE OR REPLACE PROCEDURE load_bronze_customers()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    row_count INTEGER;
    error_message STRING;
BEGIN
    -- Primeiro, tentar fazer o INSERT sem truncar
    BEGIN
        INSERT INTO bronze_customers
        SELECT 
            CAST($1 AS VARIANT) as raw,
            metadata$filename as filename,                     
            CURRENT_TIMESTAMP() as created_at                  
        FROM @POC.PUBLIC.NORTH/customers (FILE_FORMAT => 'PARQUET_FORMAT');
        
        -- Se chegou até aqui, o INSERT funcionou
        GET DIAGNOSTICS row_count = ROW_COUNT;
        
        -- Agora sim, truncar e inserir os novos dados
        TRUNCATE TABLE BRONZE_CUSTOMERS;
        
        INSERT INTO bronze_customers
        SELECT 
            CAST($1 AS VARIANT) as raw,
            metadata$filename as filename,                     
            CURRENT_TIMESTAMP() as created_at                  
        FROM @POC.PUBLIC.NORTH/customers (FILE_FORMAT => 'PARQUET_FORMAT');
        
        RETURN 'Load Bronze Customers table successfully - ' || row_count || ' rows processed';
        
    EXCEPTION
        WHEN OTHER THEN
            error_message := SQLERRM;
            RETURN 'ERROR loading Bronze Customers: ' || error_message;
    END;
END;
$$;