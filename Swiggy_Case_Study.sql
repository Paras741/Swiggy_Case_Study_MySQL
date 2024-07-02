# Swiggy Case Study:

-- 1. Find customers who have never ordered?
SELECT user_id, name
FROM users 
WHERE user_id NOT IN(SELECT user_id FROM orders);

# using joins
SELECT u.name
FROM users u
LEFT JOIN orders o
ON u.user_id = o.user_id
WHERE o.order_id is NULL;

-- 2. Find Average Price of dishes?
SELECT f.f_name food_name, AVG(m.price) avg_price_food
FROM menu m
JOIN food f
ON m.f_id = f.f_id
GROUP BY 1;

-- 3. Find the top restaurant in terms of the number of orders for a given month?
WITH CTE AS (
SELECT MONTHNAME(date) `month`, r_name, COUNT(o.order_id) no_orders
FROM restaurants r
JOIN orders o
ON r.r_id = o.r_id
GROUP BY 1,2
ORDER BY 3 DESC), CTE2 AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `month` ORDER BY no_orders DESC) `Rank`
FROM CTE)
SELECT *
FROM CTE2
WHERE `Rank` = 1;

-- 4. Find restaurants with monthly sales greater than 500?
SELECT MONTHNAME(o.date) `month`, r.r_name, SUM(o.amount) total_amount
FROM restaurants r
JOIN orders o
ON r.r_id = o.r_id
GROUP BY 1,2
having SUM(o.amount) > 500;

-- 5. Show all orders with order details for a particular customer in a particular date range?
SELECT o.date,u.name, r.r_name, f.f_name
FROM users u
JOIN orders o
ON u.user_id = o.user_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN restaurants r
ON r.r_id = o.r_id
JOIN food f
ON f.f_id = od.f_id
ORDER BY 2,1;

-- 6. Find restaurants with max repeated customers?
WITH CTE AS(
SELECT r.r_name, user_id, COUNT(*) visits
FROM restaurants r
JOIN orders o
ON r.r_id = o.r_id
GROUP BY 1,2
HAVING visits > 1
ORDER BY 3 DESC)
SELECT r_name, COUNT(*)
FROM CTE
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7. Month over Month Revenue Growth of Swiggy?
WITH CTE AS (
SELECT MONTHNAME(date) `month`, SUM(amount) total_price
FROM orders 
GROUP BY 1)
SELECT *,
(total_price - LAG(total_price) OVER()) / LAG(total_price) OVER() * 100 `month_over_month_growth`
FROM CTE;

-- 8. Find customer and his favourite favourite food?
WITH CTE AS (
SELECT u.name, f.f_name, COUNT(*) counts
FROM users u
JOIN orders o
ON u.user_id = o.user_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN food f
ON od.f_id = f.f_id
GROUP BY 1,2), CTE2 AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY name ORDER BY counts DESC) AS `rank`
FROM CTE)
SELECT name, f_name as favourite_food
FROM CTE2 
where `rank` = 1;

-- 9. Find most paired food ordered in each restaurant
WITH CTE AS (
SELECT o.date, r.r_name,f_name, COUNT(*) counts
FROM food f
JOIN order_details od
ON f.f_id = od.f_id
JOIN orders o
ON o.order_id = od.order_id
JOIN restaurants r
ON r.r_id = o.r_id
GROUP BY 1,2,3)
SELECT *
FROM CTE
WHERE counts > 1;









































