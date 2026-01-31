-- Snowpipe para carregamento automático de exchange rates do S3
-- Requer: SNS Topic configurado e Event Notification no S3
-- 
-- IMPORTANTE: Substitua o ARN do SNS Topic pelo ARN real do seu tópico
-- Você pode encontrar o ARN no console AWS SNS

-- Verificar se o stage existe (ajuste conforme necessário)
-- Se usar stage externo, ajuste o nome do stage abaixo
-- Exemplo de stage: @POC.PUBLIC.NORTH/exchange_rates/

-- Criar o Pipe com AUTO_INGEST = TRUE
-- O Snowflake criará automaticamente a fila SQS e subscreverá no SNS Topic
CREATE OR REPLACE PIPE PIPE_EXCHANGE_RATES
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:eu-west-1:815694509264:snowpipe-exchange-rates-notifications'
  AS   
  COPY INTO POC.DEV.bronze_exchange_rates (
    raw,
    filename,
    created_at
  )
  FROM (
    SELECT 
      CAST($1 AS VARIANT) AS raw,
      METADATA$FILENAME AS filename,
      CURRENT_TIMESTAMP() AS created_at
    FROM @POC.PUBLIC.SNOW_SQL/exc -- ⚠️ AJUSTE O STAGE SE NECESSÁRIO
      (FILE_FORMAT => 'JSON_FORMAT')
  )
  PATTERN = '.*\\.json$';

-- Verificar status do pipe
SELECT SYSTEM$PIPE_STATUS('PIPE_EXCHANGE_RATES');

-- Ver histórico de carregamentos (últimas 24 horas)
SELECT 
  PIPE_NAME,
  FILE_NAME,
  FILE_SIZE,
  ROW_COUNT,
  STATUS,
  LAST_LOAD_TIME,
  FIRST_ERROR_MESSAGE AS ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'BRONZE_EXCHANGE_RATES',
  START_TIME => DATEADD('hours', -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'PIPE_EXCHANGE_RATES'
ORDER BY LAST_LOAD_TIME DESC;

