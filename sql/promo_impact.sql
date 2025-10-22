WITH order_level AS (
  SELECT
    o.order_id,
    o.user_id,
    DATE(o.created_at) AS order_date,
    EXTRACT(WEEK(MONDAY) FROM o.created_at) AS iso_week,
    EXTRACT(YEAR FROM o.created_at) AS yr,
    SUM(oi.sale_price) AS gross_rev,
    SUM(CASE WHEN oi.returned_at IS NOT NULL THEN oi.sale_price ELSE 0 END) AS returned_amt
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi USING(order_id)
  WHERE o.status='Complete'
    AND EXTRACT(YEAR FROM o.created_at) BETWEEN 2019 AND 2022
  GROUP BY 1,2,3,4,5
),
flags AS (
  SELECT *,
    CASE WHEN iso_week IN (47,48) THEN TRUE ELSE FALSE END AS is_promo_window
  FROM order_level
)
SELECT
  yr,
  is_promo_window,
  COUNT(*) AS orders,
  SUM(gross_rev) AS gross_rev,
  SUM(returned_amt) AS returns,
  AVG(gross_rev) AS avg_order_value,
  SAFE_DIVIDE(SUM(returned_amt), NULLIF(SUM(gross_rev),0)) AS return_rate
FROM flags
GROUP BY 1,2
ORDER BY 1,2;
