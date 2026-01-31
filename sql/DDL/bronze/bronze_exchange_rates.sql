CREATE TABLE IF NOT EXISTS bronze_exchange_rates (
    raw VARIANT,           -- JSON bruto da API
    filename STRING,       -- Nome da fonte (API)
    created_at TIMESTAMP_NTZ  -- Timestamp de carga
);

