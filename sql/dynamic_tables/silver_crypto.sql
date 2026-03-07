CREATE OR REPLACE DYNAMIC TABLE POC.DEV.silver_crypto
LAG = '30 minutes'
WAREHOUSE = 'COMPUTE_WH'
COMMENT = 'Camada Silver - Dados normalizados a partir da Bronze RAW'
AS
SELECT 
    -- Identificador único
    MD5(CONCAT(
        raw_data:symbol::STRING, '|',
        raw_data:date::TIMESTAMP::STRING
    )) as crypto_id,
    
    -- Dimensões
    raw_data:symbol::STRING as symbol,
    raw_data:source_exchange::STRING as source_exchange,
    
    -- Fatos (tipados corretamente)
    raw_data:last::NUMBER(20,2) as last_price_usd,
    raw_data:last_btc::NUMBER(20,8) as last_price_btc,
    raw_data:lowest::NUMBER(20,2) as lowest_price_usd,
    raw_data:highest::NUMBER(20,2) as highest_price_usd,
    raw_data:daily_change_percentage::NUMBER(10,4) as daily_change_pct,
    
    -- Timestamps
    raw_data:date::TIMESTAMP_NTZ as price_date,
    DATE(raw_data:date::TIMESTAMP_NTZ) as price_day,
    HOUR(raw_data:date::TIMESTAMP_NTZ) as price_hour,
    
    -- Metadados (da bronze)
    filename,
    loaded_at as bronze_loaded_at,
    CURRENT_TIMESTAMP() as silver_created_at
    
FROM POC.DEV.bronze_crypto_raw
WHERE raw_data:symbol IS NOT NULL;  -- Filtra registros inválidos
