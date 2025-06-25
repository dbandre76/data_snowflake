CREATE OR REPLACE PROCEDURE test_snowpark()
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.11
    PACKAGES = ('snowflake-snowpark-python')
    HANDLER = 'main'
AS
$$
import snowflake.snowpark as snowpark

def main(session: snowpark.Session): 
    tableName = 'stg_customers'
    dataframe = session.table(tableName)
    dataframe.show()
    dataframe.write.save_as_table(
        "stg_customers_snowpark",
        mode="overwrite"
    )
    return "Load table executed successfully"
$$;