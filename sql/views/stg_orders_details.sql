CREATE OR REPLACE VIEW stg_orders_details as
SELECT
  $1:"order_id"::NUMBER     AS order_id,
  $1:"product_id"::NUMBER   AS product_id,
  $1:"unit_price"::FLOAT    AS unit_price,
  $1:"quantity"::NUMBER     AS quantity,
  $1:"discount"::FLOAT      AS discount,
  ($1:"quantity"::NUMBER * $1:"unit_price"::FLOAT) AS total
FROM POC.PUBLIC.orders_details;