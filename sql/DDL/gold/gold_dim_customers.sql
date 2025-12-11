CREATE TABLE IF NOT EXISTS gold_dim_customers (
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
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);