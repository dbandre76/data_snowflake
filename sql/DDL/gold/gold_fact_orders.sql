CREATE TABLE IF NOT EXISTS gold_fact_orders (
    order_id        NUMBER,
    order_date      TIMESTAMP_NTZ,
    required_date   TIMESTAMP_NTZ,
    shipped_date    TIMESTAMP_NTZ,
    product_id      NUMBER,
    unit_price      FLOAT,
    quantity        NUMBER,
    total           FLOAT,
    discount        FLOAT,
    TotalDiscount   FLOAT,
    TotalNet        FLOAT,
    QtdDays         NUMBER
);