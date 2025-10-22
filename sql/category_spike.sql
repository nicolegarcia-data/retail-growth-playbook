WITH base AS (
  SELECT
    EXTRACT(YEAR FROM o.created_at) AS yr,
    EXTRACT(WEEK(MONDAY) FROM o.created_at) AS iso_week,
    p.category AS category,
    SUM(oi.sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi USING(order_id)
  JOIN `bigquery-public-data.thelook_ecommerce.products` p USING(product_id)
  WHERE o.status = 'Complete'
    AND EXTRACT(YEAR FROM o.created_at) BETWEEN 2019 AND 2022
  GROUP BY 1,2,3
),
flagged AS (
  SELECT *,
    CASE WHEN iso_week IN (47,48) THEN 'Promo' ELSE 'Baseline' END AS period
  FROM base
)
SELECT
  yr,
  category,
  period,
  SUM(revenue) AS revenue
FROM flagged
GROUP BY 1,2,3
ORDER BY 1,2,3;
