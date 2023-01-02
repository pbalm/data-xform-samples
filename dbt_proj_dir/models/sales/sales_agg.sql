{{
  config(
    materialized = "table"
  )
}}

WITH daily_orders AS (
    SELECT
      DATE(orderdate) AS order_date, 
      PRODUCTLINE AS product_line,
      ROUND(SUM(SALES), 1) AS sales_value
    FROM
      {{ source("prod_raw", "sales_data") }}
    WHERE
      STATUS = "Shipped"
    GROUP BY
      1,
      2
)

SELECT 
    order_date, 
    product_line, 
    sales_value, 
    ROUND(SUM(sales_value) OVER (ORDER BY DATE(order_date) ROWS BETWEEN 7 PRECEDING AND CURRENT ROW  ), 1) AS rolling_average
FROM daily_orders
ORDER BY 1 DESC
