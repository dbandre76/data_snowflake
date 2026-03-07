CREATE OR REPLACE PIPE PIPE_CRYPTO
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:eu-west-1:815694509264:sns_crypto'
  AS   
COPY INTO bronze_crypto_raw (raw_data, filename, loaded_at)
FROM (
    SELECT 
        $1 as raw_data,                          -- JSON inteiro como VARIANT
        METADATA$FILENAME as filename,            -- Nome do arquivo
        CURRENT_TIMESTAMP() as loaded_at          -- Timestamp da carga
    FROM @POC.PUBLIC.CRYPTO
    (FILE_FORMAT => 'json_crypto')
)
PATTERN = '.*\.json$';                             -- Apenas arquivos .json
