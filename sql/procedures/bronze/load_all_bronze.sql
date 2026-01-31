-- Dynamic procedure to load all bronze tables automatically
-- Detects entities from stage and loads them dynamically
-- Replicates the notebook logic as a reusable procedure
CREATE OR REPLACE PROCEDURE load_all_bronze()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
AS
$$
import re
from snowflake.snowpark import Session

def get_entity(path: str) -> str:
    """Extract entity from path: multicloud/<entity>/arquivo.parquet"""
    match = re.search(r'/multicloud/([^/]+)/', path)
    return match.group(1).upper() if match else None

def main(session: Session) -> str:
    try:
        # Step 1: List files and extract entities
        files = session.sql("LIST @POC.PUBLIC.NORTH;").collect()
        file_names = [f["name"] for f in files]
        
        entities = sorted({get_entity(p) for p in file_names if get_entity(p)})
        
        if not entities:
            return 'No entities found in stage @POC.PUBLIC.NORTH'
        
        results = []
        
        # Step 2: For each entity, create table and load data
        for entity in entities:
            bronze_table = f"BRONZE_{entity}"
            entity_lower = entity.lower()
            
            # Create table if not exists
            create_table_sql = f"""
                CREATE TABLE IF NOT EXISTS {bronze_table} (
                    raw        VARIANT,
                    filename   STRING,
                    created_at TIMESTAMP_NTZ
                )
                COMMENT = 'Bronze layer para dados de {entity_lower} - RAW data';
            """
            session.sql(create_table_sql).collect()
            
            # Truncate table
            session.sql(f"TRUNCATE TABLE {bronze_table};").collect()
            
            # Load data
            copy_sql = f"""
                COPY INTO {bronze_table} (raw, filename, created_at)
                FROM (
                    SELECT
                        $1::VARIANT AS raw,
                        metadata$filename AS filename,
                        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS created_at
                    FROM @POC.PUBLIC.NORTH/{entity_lower}/
                        (FILE_FORMAT => 'PARQUET_FORMAT')
                );
            """
            
            copy_result = session.sql(copy_sql).collect()
            # COPY INTO returns result with 'rows_loaded' or 'rows_parsed' column
            rows_loaded = copy_result[0].get("rows_loaded", copy_result[0].get("rows_parsed", 0)) if copy_result else 0
            
            results.append(f"{entity}: {rows_loaded} rows loaded")
        
        return 'All Bronze tables loaded successfully:\n' + '\n'.join(results)
        
    except Exception as e:
        return f'Error: {str(e)}'
$$;

