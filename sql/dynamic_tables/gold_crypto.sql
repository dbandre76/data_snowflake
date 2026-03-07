-- Exemplo de Gold: Médias diárias por símbolo
CREATE OR REPLACE DYNAMIC TABLE POC.DEV.gold_crypto_daily_metrics
LAG = '24 hours'
WAREHOUSE = 'COMPUTE_WH'
AS
SELECT 
    symbol,
    DATE(price_date) as trading_day,
    COUNT(*) as samples_per_day,
    AVG(last_price_usd) as avg_price_usd,
    MIN(last_price_usd) as min_price_usd,
    MAX(last_price_usd) as max_price_usd,
    STDDEV(last_price_usd) as price_volatility,
    (MAX(last_price_usd) - MIN(last_price_usd)) / AVG(last_price_usd) * 100 as daily_range_pct
FROM POC.DEV.silver_crypto_prices
GROUP BY symbol, DATE(price_date);