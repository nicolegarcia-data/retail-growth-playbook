-- Step 1: Identify each user's first purchase month (their cohort)
WITH first_order AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), MONTH) AS cohort_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

-- Step 2: Link every subsequent order to that cohort
orders_clean AS (
  SELECT
    o.order_id,
    o.user_id,
    DATE_TRUNC(o.created_at, MONTH) AS order_month,
    o.created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  WHERE o.status = 'Complete'
    AND EXTRACT(YEAR FROM o.created_at) BETWEEN 2019 AND 2022
)

-- Step 3: Count active users and orders by cohort
SELECT
  f.cohort_month,
  o.order_month,
  COUNT(DISTINCT o.user_id) AS active_users,
  COUNT(DISTINCT o.order_id) AS orders
FROM orders_clean o
JOIN first_order f USING (user_id)
GROUP BY 1, 2
ORDER BY 1, 2;
