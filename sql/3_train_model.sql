-- Sentinel-X v2: Modelo sin data leakage
-- Features derivadas de comportamiento, no de las reglas del label
CREATE OR REPLACE MODEL `green-post-491906-b7.fraud_intelligence.sentinel_model`
OPTIONS(
    model_type='LOGISTIC_REG',
    input_label_cols=['is_fraud'],
    auto_class_weights=TRUE,
    data_split_method='RANDOM',
    data_split_eval_fraction=0.2
) AS
SELECT
  -- Features de comportamiento temporal (no usadas para generar is_fraud)
  tx_velocity_24h,
  amount_z_score,
  hour_of_day,

  -- device_risk_level: sí estaba en la regla de fraude, SE ELIMINA
  -- amount: sí estaba en la regla de fraude, SE ELIMINA  
  -- tx_category: sí estaba en la regla de fraude, SE ELIMINA

  is_fraud
FROM `green-post-491906-b7.fraud_intelligence.transactions_features`
WHERE RAND() < 0.20;
