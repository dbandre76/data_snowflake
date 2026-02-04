CREATE OR REPLACE PROCEDURE gold_dim_customers_scd2()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$

BEGIN

    -- Step 1: UPDATE -  Close expired records when data changed
    UPDATE gold_dim_customers_scd2 AS target
    SET 
        target.expiry_date = CURRENT_TIMESTAMP(),
        target.is_current = FALSE
    WHERE target.customer_id IN (
        SELECT s.customer_id
        FROM silver_customers s
        INNER JOIN gold_dim_customers_scd2 g 
            ON s.customer_id = g.customer_id 
            AND g.is_current = TRUE
        WHERE MD5(
            NVL(s.company_name,'')  || '|' ||
            NVL(s.contact_name,'')  || '|' ||
            NVL(s.contact_title,'') || '|' ||
            NVL(s.address,'')       || '|' ||
            NVL(s.city,'')          || '|' ||
            NVL(s.postal_code,'')   || '|' ||
            NVL(s.country,'')       || '|' ||
            NVL(s.phone,'')         || '|' ||
            NVL(s.fax,'')
        ) <> g.hash_diff
    )
    AND target.is_current = TRUE;

    -- Step 2: INSERT - Create new records for customers without current record
    -- This covers: new customers AND customers whose old record was closed by MERGE
    INSERT INTO gold_dim_customers_scd2 (
        customer_id,
        company_name,
        contact_name,
        contact_title,
        address,
        city,
        postal_code,
        country,
        phone,
        fax,
        hash_diff,
        effective_date,
        expiry_date,
        is_current
    )
    SELECT
        s.customer_id,
        s.company_name,
        s.contact_name,
        s.contact_title,
        s.address,
        s.city,
        s.postal_code,
        s.country,
        s.phone,
        s.fax,
        MD5(
            NVL(s.company_name,'')  || '|' ||
            NVL(s.contact_name,'')  || '|' ||
            NVL(s.contact_title,'') || '|' ||
            NVL(s.address,'')       || '|' ||
            NVL(s.city,'')          || '|' ||
            NVL(s.postal_code,'')   || '|' ||
            NVL(s.country,'')       || '|' ||
            NVL(s.phone,'')         || '|' ||
            NVL(s.fax,'')
        ) AS hash_diff,
        CURRENT_TIMESTAMP() AS effective_date,
        NULL AS expiry_date,
        TRUE AS is_current
    FROM silver_customers s
    WHERE NOT EXISTS (
        SELECT 1
        FROM gold_dim_customers_scd2 g
        WHERE g.customer_id = s.customer_id
          AND g.is_current = TRUE
    );

RETURN 'Load Gold Dim Customers SCD2 table successfully';

END;

$$;

