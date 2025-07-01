--- Procedure to load the gold fact orders table
CREATE OR REPLACE PROCEDURE load_gold_fact_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE GOLD_FACT_ORDERS;

    INSERT INTO GOLD_FACT_ORDERS
select 
    o.order_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    od.product_id,
    od.unit_price,
    od.quantity,
    od.total,
    od.discount,
    od.total * od.discount as TotalDiscount,
    od. TOTAL - (od.total * od.discount ) as TotalNet,
    datediff(day,order_date,required_date) QtdDays
from silver_orders o 
inner join silver_orders_details od     
    on o.order_id = od.order_id;

    RETURN 'Load Gold Facto Orders table successfully';
END;
$$;