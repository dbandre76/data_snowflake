-- Task Bronze
CREATE OR REPLACE TASK task_bronze_customers
  WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 5 * * * UTC'
AS call  load_bronze_customers()
;


-- Task Silver
CREATE OR REPLACE TASK task_silver_customers
  WAREHOUSE = COMPUTE_WH
  after task_bronze_customers
AS 
    call load_silver_customers()
;

-- Task Gold
CREATE OR REPLACE TASK task_gold_customers
  WAREHOUSE = COMPUTE_WH
  after task_silver_customers
AS 
    call gold_dim_customers()
;
