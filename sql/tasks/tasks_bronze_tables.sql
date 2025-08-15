CREATE OR REPLACE TASK task_load_bronze_tables
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 7 * * * UTC'
AS
  BEGIN
    CALL load_bronze_table('dev', 'customers', 'bronze_customers');
    CALL load_bronze_table('dev', 'orders', 'bronze_orders');
    CALL load_bronze_table('dev', 'orders_details', 'bronze_orders_details');
    CALL load_bronze_table('dev', 'products', 'bronze_products');
  END;