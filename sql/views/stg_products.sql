CREATE OR REPLACE VIEW stg_products AS
SELECT
  $1:"product_id"::NUMBER           AS product_id,
  UPPER($1:"product_name"::STRING)  AS product_name,
  $1:"supplier_id"::NUMBER          AS supplier_id,
  $1:"category_id"::NUMBER          AS category_id,
  UPPER($1:"quantity_per_unit"::STRING)    AS quantity_per_unit,
  $1:"unit_price"::FLOAT            AS unit_price,
  $1:"units_in_stock"::NUMBER       AS units_in_stock,
  $1:"units_on_order"::NUMBER       AS units_on_order,
  $1:"reorder_level"::NUMBER        AS reorder_level,
  $1:"discontinued"::NUMBER         AS discontinued
FROM products;
