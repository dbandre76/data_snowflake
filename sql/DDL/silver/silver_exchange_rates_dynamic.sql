-- Dynamic Table approach: Automatically refreshes from Bronze
-- Simpler than Stream, but processes all data on each refresh
-- Uses LATERAL FLATTEN to extract each currency pair from nested JSON
CREATE OR REPLACE DYNAMIC TABLE silver_exchange_rates_dt
TARGET_LAG = '1 minute'
WAREHOUSE = 'COMPUTE_WH'
AS
SELECT
    f.value:code::STRING || '-' || f.value:codein::STRING AS currency_pair,
    f.value:code::STRING AS code,
    f.value:codein::STRING AS codein,
    f.value:name::STRING AS name,
    TRY_TO_DOUBLE(f.value:bid::STRING) AS bid,
    TRY_TO_DOUBLE(f.value:ask::STRING) AS ask,
    TRY_TO_DOUBLE(f.value:high::STRING) AS high,
    TRY_TO_DOUBLE(f.value:low::STRING) AS low,
    TRY_TO_DOUBLE(f.value:varBid::STRING) AS var_bid,
    TRY_TO_DOUBLE(f.value:pctChange::STRING) AS pct_change,
    TRY_TO_NUMBER(f.value:timestamp::STRING) AS timestamp,
    TRY_TO_TIMESTAMP_NTZ(f.value:create_date::STRING) AS create_date,
    TRY_TO_TIMESTAMP_NTZ(b.raw:_extracted_at::STRING) AS extracted_at,
    CURRENT_TIMESTAMP() AS created_at
FROM bronze_exchange_rates b
CROSS JOIN LATERAL FLATTEN(INPUT => b.raw) f
WHERE f.key != '_extracted_at'
  AND f.key != '_pairs_requested'
  AND f.key != '_total_pairs'
  AND b.raw IS NOT NULL
  AND f.value IS NOT NULL;

