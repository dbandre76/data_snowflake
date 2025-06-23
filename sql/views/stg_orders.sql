create or replace view identifier('POC.' || $TARGET_SCHEMA || '.stg_orders') as (
with orders as (
    select 
        o.order_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.ship_country,
        od.product_id,
        od.unit_price,
        od.quantity,
        od.discount,
        o.freight
    from identifier('POC.' || $TARGET_SCHEMA || '.orders') o
    inner join identifier('POC.' || $TARGET_SCHEMA || '.orders_details') od 
        on o.order_id = od.order_id
)
select
    o.*,
    o.unit_price * quantity as Total
from orders o 
);