CREATE OR REPLACE TABLE bronze_crypto_raw (
    raw_data VARIANT,                    -- Coluna para armazenar o JSON inteiro
    filename STRING,                     -- Nome do arquivo de origem
    loaded_at TIMESTAMP_NTZ              -- Timestamp da carga (sem timezone)
);
