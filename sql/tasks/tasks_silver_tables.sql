-- Task 1
CREATE OR REPLACE TASK task_load_silver_customers
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 15 * * * UTC'
AS
  CALL load_silver_customers();

-- Task 2, depende da anterior
CREATE OR REPLACE TASK task_load_silver_orders
  WAREHOUSE = COMPUTE_WH
  AFTER task_load_silver_customers
AS
  CALL load_silver_orders();

-- Task 3, depende da anterior
CREATE OR REPLACE TASK task_load_silver_orders_details
  WAREHOUSE = COMPUTE_WH
  AFTER task_load_silver_orders
AS
  CALL load_silver_orders_details();

-- Task 4, depende da anterior
CREATE OR REPLACE TASK task_load_silver_products
  WAREHOUSE = COMPUTE_WH
  AFTER task_load_silver_orders_details
AS
  CALL load_silver_products();


ALTER TASK task_load_silver_customers RESUME;