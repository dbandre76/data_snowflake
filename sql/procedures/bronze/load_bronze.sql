CREATE OR REPLACE PROCEDURE load_bronze_table(
    schema_name STRING,
    dir_name STRING,
    table_name STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  stage_path STRING;
  full_table_name STRING;
BEGIN
  stage_path := '@NORTH/' || dir_name || '/';
  full_table_name := schema_name || '.' || table_name;

  -- Tenta criar a tabela (ignora erro se já existir)
  BEGIN
    EXECUTE IMMEDIATE '
      CREATE TABLE ' || full_table_name || ' (
        raw VARIANT,
        filename STRING,
        load_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
      )';
  EXCEPTION
    WHEN OTHER THEN
      -- tabela já existe, não faz nada
      NULL;
  END;

  -- Trunca a tabela
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || full_table_name;

  -- Carrega os dados do stage
  EXECUTE IMMEDIATE '
    INSERT INTO ' || full_table_name || ' (raw, filename)
    SELECT 
      $1,
      METADATA$FILENAME
    FROM ' || stage_path || ' (FILE_FORMAT => ''PARQUET_FORMAT'')
    WHERE METADATA$FILENAME ILIKE ''%.parquet''';

  RETURN 'Bronze load for ' || full_table_name || ' completed.';
END;
$$;