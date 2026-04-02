CREATE OR REPLACE TABLE `green-post-491906-b7.fraud_intelligence.transactions_features` AS

WITH base AS (
  SELECT
    tx_id,
    user_id,
    amount,
    tx_timestamp,
    tx_category,
    device_risk_level,
    is_fraud,

    EXTRACT(HOUR FROM tx_timestamp) AS hour_of_day,

    COUNT(*) OVER (
      PARTITION BY user_id
      ORDER BY UNIX_SECONDS(tx_timestamp)
      RANGE BETWEEN 86400 PRECEDING AND 1 PRECEDING
    ) AS tx_velocity_24h,

    AVG(amount) OVER (
      PARTITION BY user_id
      ORDER BY tx_timestamp
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) AS _user_avg_hist,

    STDDEV(amount) OVER (
      PARTITION BY user_id
      ORDER BY tx_timestamp
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) AS _user_std_hist

  FROM `green-post-491906-b7.fraud_intelligence.transactions`
)

SELECT
  tx_id,
  user_id,
  amount,
  tx_timestamp,
  tx_category,
  device_risk_level,
  is_fraud,
  hour_of_day,
  tx_velocity_24h,
  CASE
    WHEN _user_std_hist IS NULL OR _user_std_hist = 0 THEN 0.0
    ELSE (amount - _user_avg_hist) / _user_std_hist
  END AS amount_z_score
FROM base;
