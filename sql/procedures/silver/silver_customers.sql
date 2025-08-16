-- Test Customer Table
CREATE OR REPLACE PROCEDURE load_silver_customers()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE SILVER_CUSTOMERS;

    INSERT INTO SILVER_CUSTOMERS
    SELECT
    upper($1:"customer_id")        AS customer_id,
    upper($1:"company_name")       AS company_name,
    upper($1:"contact_name")       AS contact_name,
    upper($1:"contact_title")      AS contact_title,
    upper($1:"address")            AS address,
    upper($1:"city")               AS city,
    upper($1:"postal_code")        AS postal_code,
    upper($1:"country")            AS country,
    upper($1:"phone")              AS phone,
    upper($1:"fax")                AS fax
from @NORTH/customers/customers
(FILE_FORMAT => 'PARQUET_FORMAT');

    RETURN 'Load Siver Customers table successfully';
END;
$$;