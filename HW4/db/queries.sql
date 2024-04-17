-- Q#1
SELECT COUNT(DISTINCT c.customer_id) as count_customer_with_no_order 
FROM customers c 
LEFT JOIN orders o 
	ON c.customer_id = o.customer_id 
WHERE o.customer_id IS NULL;

-- Q#2
SELECT s.first_name, s.last_name 
FROM staffs s 
JOIN orders o 
	ON s.staff_id = o.staff_id 
GROUP BY o.staff_id 
ORDER BY COUNT(o.order_id) DESC 
LIMIT 3;

-- Q#3
SELECT o.* 
FROM orders o 
JOIN customers c 
	ON o.customer_id = c.customer_id 
WHERE o.order_status = 'Processing' OR c.first_name LIKE 'A%';

-- Q#4
SELECT product_id, 
	   product_name, 
	   list_price
FROM products 
WHERE list_price > (SELECT AVG(list_price) as average_price FROM products);

