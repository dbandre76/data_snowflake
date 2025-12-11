-- SILVER_ORDERS
CREATE TABLE IF NOT EXISTS silver_orders (
  order_id           NUMBER,
  customer_id        STRING,
  employee_id        NUMBER,
  order_date         TIMESTAMP_NTZ,
  required_date      TIMESTAMP_NTZ,
  shipped_date       TIMESTAMP_NTZ,
  ship_via           NUMBER,
  freight            FLOAT,
  ship_name          STRING,
  ship_address       STRING,
  ship_city          STRING,
  ship_postal_code   STRING,
  ship_country       STRING,
  created_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);