CREATE TABLE IF NOT EXISTS gold_dim_products (
    product_sk BIGINT AUTOINCREMENT,
    product_id NUMBER(38,0),
    product_name VARCHAR(16777216),
    supplier_id NUMBER(38,0),
    category_id NUMBER(38,0),
    quantity_per_unit VARCHAR(16777216),
    unit_price FLOAT,
    units_in_stock NUMBER(38,0),
    units_on_order NUMBER(38,0),
    reorder_level NUMBER(38,0),
    discontinued NUMBER(38,0),
    hash_diff VARCHAR(300),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
