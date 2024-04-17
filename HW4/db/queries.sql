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

-- Q#5
WITH temp AS 
(
	SELECT store_id, 
		   COUNT(staff_id) as staffs_count 
	FROM staffs GROUP BY store_id
)
SELECT store_id
FROM temp 
WHERE temp.staffs_count >=2 AND store_id IN (SELECT store_id FROM customers WHERE LENGTH(first_name) = 5);

-- Q#6
WITH temp AS 
(
	SELECT store_id, 
		   COUNT(staff_id) AS stafss_count_with_name_len_5 
	FROM staffs 
	WHERE LENGTH(first_name) = 5 
	GROUP BY store_id
) 
SELECT store_id 
FROM temp 
WHERE stafss_count_with_name_len_5 >= 2;

