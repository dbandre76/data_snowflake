CREATE OR REPLACE PROCEDURE gold_dim_products()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$

BEGIN

MERGE INTO gold_dim_products as  t 
using (
 SELECT  
        PRODUCT_ID,
        PRODUCT_NAME,
        SUPPLIER_ID,
        CATEGORY_ID,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
          MD5(
            NVL(product_name, '')              || '|' ||
            NVL(TO_CHAR(supplier_id), '')      || '|' ||
            NVL(TO_CHAR(category_id), '')      || '|' ||
            NVL(quantity_per_unit, '')         || '|' ||
            NVL(TO_CHAR(unit_price), '')       || '|' ||
            NVL(TO_CHAR(units_in_stock), '')   || '|' ||
            NVL(TO_CHAR(units_on_order), '')   || '|' ||
            NVL(TO_CHAR(reorder_level), '')    || '|' ||
            NVL(TO_CHAR(discontinued), '')
        ) AS hash_diff
        FROM silver_products
) AS s
    on t.product_id = s.product_id

    
when matched and 
t.hash_diff <> s.hash_diff then 

update set 
    t.product_id = s.product_id,
    t.PRODUCT_NAME = s.PRODUCT_NAME,
    t.SUPPLIER_ID = s.SUPPLIER_ID,
    t.CATEGORY_ID = s.CATEGORY_ID,
    t.QUANTITY_PER_UNIT = s.QUANTITY_PER_UNIT,
    t.UNIT_PRICE = s.UNIT_PRICE,
    t.UNITS_IN_STOCK = s.UNITS_IN_STOCK,
    t.UNITS_ON_ORDER = s.UNITS_ON_ORDER,
    t.REORDER_LEVEL = s.REORDER_LEVEL,
    t.DISCONTINUED = s.DISCONTINUED,
    t.hash_diff = s.hash_diff

    when not matched then 
    insert (
        PRODUCT_ID,
        PRODUCT_NAME,
        SUPPLIER_ID,
        CATEGORY_ID,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
        hash_diff
    )

    values (

     PRODUCT_ID,
        s.PRODUCT_NAME,
        s.SUPPLIER_ID,
        s.CATEGORY_ID,
        s.QUANTITY_PER_UNIT,
        s.UNIT_PRICE,
        s.UNITS_IN_STOCK,
        s.UNITS_ON_ORDER,
        s.REORDER_LEVEL,
        s.DISCONTINUED,
        s.hash_diff
    )
;

    Return 'Dimensão de Produtos Carregada com sucesso';

    END;
    $$;