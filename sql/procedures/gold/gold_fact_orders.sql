--- Procedure to load the gold fact orders table
CREATE OR REPLACE PROCEDURE gold_fact_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
   MERGE INTO gold_fact_orders AS target
USING (
    with fact as (
        select 
            o.order_id,
            c.customer_sk,
            p.product_sk,
            dc_order.date_sk as order_date_sk,
            dc_required.date_sk as required_date_sk,  
            dc_shipped.date_sk as shipped_date_sk,
            od.unit_price,
            od.quantity,
            od.discount,
            od.quantity * od.unit_price as total,
            -- HASH para detectar mudanças
            MD5(
                NVL(TO_CHAR(o.order_id), '') || '|' ||
                NVL(TO_CHAR(c.customer_sk), '') || '|' ||
                NVL(TO_CHAR(p.product_sk), '') || '|' ||
                NVL(TO_CHAR(dc_order.date_sk), '') || '|' ||
                NVL(TO_CHAR(dc_required.date_sk), '') || '|' ||
                NVL(TO_CHAR(dc_shipped.date_sk), '') || '|' ||
                NVL(TO_CHAR(od.unit_price), '') || '|' ||
                NVL(TO_CHAR(od.quantity), '') || '|' ||
                NVL(TO_CHAR(od.discount), '')
            ) AS hash_diff
        from silver_orders o 
        inner join silver_orders_details od 
            on o.order_id = od.order_id
        left join gold_dim_customers c 
            on o.customer_id = c.customer_id
        left join gold_dim_products p
            on od.product_id = p.product_id
        left join gold_dim_calendar dc_order
            on o.order_date = dc_order.date_key
        left join gold_dim_calendar dc_required
            on o.required_date = dc_required.date_key
        left join gold_dim_calendar dc_shipped
            on o.shipped_date = dc_shipped.date_key
    )
    select *,
        total * discount as total_discount,
        total - (total * discount) as total_liquid
    from fact
) AS source
ON target.order_id = source.order_id 
   AND target.product_sk = source.product_sk

WHEN MATCHED AND target.hash_diff <> source.hash_diff THEN
    UPDATE SET
        target.customer_sk = source.customer_sk,
        target.order_date_sk = source.order_date_sk,
        target.required_date_sk = source.required_date_sk,
        target.shipped_date_sk = source.shipped_date_sk,
        target.unit_price = source.unit_price,
        target.quantity = source.quantity,
        target.discount = source.discount,
        target.total = source.total,
        target.total_discount = source.total_discount,
        target.total_liquid = source.total_liquid,
        target.hash_diff = source.hash_diff,
        target.last_updated = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
    INSERT (
        order_id,
        customer_sk,
        product_sk,
        order_date_sk,
        required_date_sk,
        shipped_date_sk,
        unit_price,
        quantity,
        discount,
        total,
        total_discount,
        total_liquid,
        hash_diff,
        created_date,
        last_updated
    )
    VALUES (
        source.order_id,
        source.customer_sk,
        source.product_sk,
        source.order_date_sk,
        source.required_date_sk,
        source.shipped_date_sk,
        source.unit_price,
        source.quantity,
        source.discount,
        source.total,
        source.total_discount,
        source.total_liquid,
        source.hash_diff,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    ) 
;

    RETURN 'Load Gold Fact Orders table successfully';
END;
$$;