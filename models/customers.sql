{{ config(materialized='table') }}

WITH customers AS (

    SELECT
        id AS customer_id,
        first_name,
        last_name
    FROM HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_CUSTOMERS

),

orders AS (

    SELECT
        id AS order_id,
        user_id AS customer_id,
        order_date
    FROM HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_ORDERS

),

payments AS (

    SELECT
        order_id,
        amount
    FROM HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_PAYMENTS

),

customer_orders AS (

    SELECT
        customer_id,
        MIN(order_date) AS first_order,
        MAX(order_date) AS most_recent_order,
        COUNT(order_id) AS number_of_orders
    FROM orders
    GROUP BY customer_id

),

customer_payments AS (

    SELECT
        o.customer_id,
        SUM(p.amount) AS customer_lifetime_value
    FROM payments p
    JOIN orders o
        ON p.order_id = o.order_id
    GROUP BY o.customer_id

)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    co.first_order,
    co.most_recent_order,
    co.number_of_orders,
    cp.customer_lifetime_value
FROM customers c
LEFT JOIN customer_orders co
    ON c.customer_id = co.customer_id
LEFT JOIN customer_payments cp
    ON c.customer_id = cp.customer_id