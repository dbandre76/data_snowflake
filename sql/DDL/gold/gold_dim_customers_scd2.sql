CREATE TABLE IF NOT EXISTS gold_dim_customers_scd2 (
    customer_sk BIGINT AUTOINCREMENT,
    customer_id VARCHAR(20),
    company_name VARCHAR(100),
    contact_name VARCHAR(200),
    contact_title VARCHAR(100),
    address VARCHAR(300),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    country VARCHAR(100),
    phone VARCHAR(100),
    fax VARCHAR(100),
    hash_diff VARCHAR(300),
    effective_date TIMESTAMP_NTZ NOT NULL,
    expiry_date TIMESTAMP_NTZ,
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

