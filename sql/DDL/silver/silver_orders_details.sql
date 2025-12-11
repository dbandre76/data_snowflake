CREATE TABLE IF NOT EXISTS silver_orders_details (
  order_id      NUMBER,
  product_id    NUMBER,
  unit_price    FLOAT,
  quantity      NUMBER,
  discount      FLOAT,
  total         FLOAT,  -- Calculated field: quantity * unit_price
  created_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);