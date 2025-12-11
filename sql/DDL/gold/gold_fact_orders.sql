CREATE TABLE IF NOT EXISTS gold_fact_orders (
    order_sk BIGINT AUTOINCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    customer_sk BIGINT NOT NULL,
    product_sk BIGINT NOT NULL,
    order_date_sk BIGINT NOT NULL,
    required_date_sk BIGINT,
    shipped_date_sk BIGINT,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    discount DECIMAL(4,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    total_discount DECIMAL(10,2) NOT NULL,
    total_liquid DECIMAL(10,2) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    created_date TIMESTAMP NOT NULL,
    last_updated TIMESTAMP NOT NULL
);
