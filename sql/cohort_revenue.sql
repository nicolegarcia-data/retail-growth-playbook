WITH items AS (
  SELECT
    oi.order_id, oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
),
returns AS (
  SELECT
    order_id,
    SUM(sale_price) AS returned_amt
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE returned = TRUE
  GROUP BY order_id
),
order_rev AS (
  SELECT
    o.order_id,
    o.user_id,
    DATE_TRUNC(o.created_at, MONTH) AS order_month,
    SUM(i.sale_price) AS gross_revenue,
    IFNULL(r.returned_amt, 0) AS returned_amt,
    SUM(i.sale_price) - IFNULL(r.returned_amt, 0) AS net_revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN items i USING(order_id)
  LEFT JOIN returns r USING(order_id)
  WHERE o.status='Complete'
    AND EXTRACT(YEAR FROM o.created_at) BETWEEN 2019 AND 2022
  GROUP BY 1,2,3,5
),
first_order AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), MONTH) AS cohort_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status='Complete'
  GROUP BY user_id
)
SELECT
  f.cohort_month,
  orv.order_month,
  SUM(orv.net_revenue) AS cohort_net_revenue,
  COUNT(DISTINCT orv.user_id) AS unique_buyers
FROM order_rev orv
JOIN first_order f USING(user_id)
GROUP BY 1,2
ORDER BY 1,2;
