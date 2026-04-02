CREATE OR REPLACE TABLE `green-post-491906-b7.fraud_intelligence.transactions` AS
WITH raw_data AS (
  SELECT
    GENERATE_UUID() as tx_id,
    CAST(FLOOR(1000 + (50000 - 1000) * RAND()) AS INT64) as user_id,
    ROUND(5 + (8000 - 5) * RAND(), 2) as amount,
    TIMESTAMP_SECONDS(CAST(1704067200 + (1711929600 - 1704067200) * RAND() AS INT64)) as tx_timestamp,
    CASE 
      WHEN RAND() < 0.30 THEN 'In-Game Purchase'
      WHEN RAND() < 0.55 THEN 'P2P Transfer'
      WHEN RAND() < 0.75 THEN 'Crypto Top-up'
      WHEN RAND() < 0.90 THEN 'Retail'
      ELSE 'Subscription'
    END as tx_category,
    CAST(FLOOR(1 + (5 - 1) * RAND()) AS INT64) as device_risk_level
  FROM
    -- Técnica de multiplicación de filas (10,000 x 1,000 = 10M)
    UNNEST(GENERATE_ARRAY(1, 10000)) as a
    CROSS JOIN UNNEST(GENERATE_ARRAY(1, 1000)) as b
)
SELECT 
  tx_id,
  user_id,
  amount,
  tx_timestamp,
  tx_category,
  device_risk_level,
  CASE 
    WHEN (tx_category IN ('Crypto Top-up', 'In-Game Purchase') AND amount > 6000 AND device_risk_level > 3) THEN 1
    WHEN (tx_category = 'P2P Transfer' AND amount < 50 AND device_risk_level = 5 AND RAND() < 0.4) THEN 1
    WHEN (RAND() < 0.01) THEN 1 
    ELSE 0 
  END as is_fraud
FROM raw_data;
