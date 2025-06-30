CREATE OR REPLACE TABLE silver_products (
  product_id         NUMBER,
  product_name       STRING,
  supplier_id        NUMBER,
  category_id        NUMBER,
  quantity_per_unit  STRING,
  unit_price         FLOAT,
  units_in_stock     NUMBER,
  units_on_order     NUMBER,
  reorder_level      NUMBER,
  discontinued       NUMBER
);