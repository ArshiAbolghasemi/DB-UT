-- Q#1
SELECT COUNT(DISTINCT c.customer_id) as count_customer_with_no_order 
FROM customers c 
LEFT JOIN orders o 
	ON c.customer_id = o.customer_id 
WHERE o.customer_id IS NULL;

