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

-- Q#7
WITH temp AS 
(
	SELECT customer_id, 
	       COUNT(DISTINCT o.order_id) AS total_orders_count,
		   SUM(oi.quantity) / COUNT(DISTINCT o.order_id) AS avg_quantity
    FROM orders o 
	JOIN order_items oi 
		ON o.order_id = oi.order_id 
	GROUP BY customer_id
) 
SELECT c.customer_id, 
       c.first_name, 
	   c.last_name, 
	   t.avg_quantity
FROM customers c 
JOIN temp t 
	ON c.customer_id = t.customer_id 
WHERE t.total_orders_count > 8;

-- Q#8
SELECT p.product_id, 
       p.product_name, 
	   sps.quantity 
FROM stocks sps 
JOIN products p 
	ON sps.product_id = p.product_id 
JOIN stores s 
	ON sps.store_id = s.store_id 
WHERE sps.quantity > 0;

-- Q#9
WITH temp AS 
(
	SELECT p.product_id, 
		   p.brand_id, 
		   SUM(oi.quantity) AS orders_quantity 
	FROM products p 
	JOIN order_items oi 
		ON p.product_id = oi.product_id 
	GROUP BY brand_id, product_id
)
SELECT b.brand_name, 
	   p.product_id, 
	   p.list_price 
FROM products p 
JOIN brands b 
	ON p.brand_id = b.brand_id 
WHERE p.product_id IN (SELECT product_id 
					   FROM temp t1 
					   JOIN (SELECT brand_id, 
					   				MAX(orders_quantity) AS max_sales_quantity 
									FROM temp 
									GROUP BY brand_id) t2 
					   ON t1.brand_id = t2.brand_id 
					   WHERE t1.brand_id = t2.brand_id AND t1.orders_quantity = t2.max_sales_quantity);

-- Q#10
WITH temp AS 
(
	SELECT oi.product_id, 
		   COUNT(c.customer_id) AS count_customers 
	FROM orders o 
	JOIN order_items oi 
		ON oi.order_id = o.order_id 
	JOIN customers c 
		ON c.customer_id = o.customer_id 
	GROUP BY oi.product_id
) 
SELECT product_id, count_customers 
FROM temp 
WHERE count_customers > 40
ORDER BY count_customers DESC;

-- Q#11
SELECT DISTINCT c.customer_id, 
	   c.first_name, 
	   c.last_name 
FROM orders o 
JOIN customers c 
	ON o.customer_id = c.customer_id 
JOIN stores s 
	ON o.store_id = s.store_id 
WHERE c.city != s.city;

-- Q#12
CREATE VIEW category_sales_per_day AS 
WITH temp AS 
(
	SELECT p.category_id, 
		   o.order_date, 
		   SUM(oi.quantity * oi.list_price) as total_sales 
	FROM order_items oi 
	JOIN orders o 
		ON oi.order_id = o.order_id 
	JOIN products p 
		ON p.product_id = oi.product_id 
	GROUP BY p.category_id, o.order_date
) 
SELECT c.category_name, 
	   t.order_date as date, 
	   t.total_sales 
FROM temp t 
JOIN categories c 
	ON t.category_id = t.category_id;

-- Q#13
CREATE VIEW order_item_product_name_order_status AS 
SELECT oi.item_id AS order_item_id, 
	   CASE 
			WHEN o.order_status = 1 THEN 'Pending' 
			WHEN o.order_status = 2 THEN 'Processing' 
			WHEN o.order_status = 3 THEN 'Rejected' 
			WHEN o.order_status = 4 THEN 'Completed' 
	   END AS order_status, 
	   p.product_name 
FROM order_items oi
JOIN orders o 
	ON oi.order_id = o.order_id 
JOIN products p 
	ON oi.product_id = p.product_id;

-- Q#14
CREATE VIEW store_brand_min_auntity AS 
WITH temp AS 
(
	SELECT s.store_id, 
		   p.brand_id, 
		   SUM(sps.quantity) as total_quantity_brand 
	FROM stocks sps 
	JOIN products p 
		ON sps.product_id = p.product_id 
	JOIN stores s 
		ON sps.store_id = s.store_id 
	GROUP BY s.store_id, p.brand_id
) 
SELECT t1.store_id, 
	   t1.brand_id 
FROM temp t1 
JOIN (SELECT store_id, 
			 MIN(total_quantity_brand) AS brand_min_quantity 
	  FROM temp 
	  GROUP BY store_id) t2 
ON t1.store_id = t2.store_id 
WHERE t1.total_quantity_brand = t2.brand_min_quantity;

-- Q#15
CREATE TRIGGER inc_stocks_qnt_dlt_oi
AFTER DELETE ON order_items 
FOR EACH ROW 
UPDATE stocks 
SET quantity = quantity + OLD.quantity 
WHERE product_id = OLD.product_id AND store_id = (SELECT DISTINCT store_id 
												  FROM order_items oi 
												  JOIN orders o 
												      ON oi.order_id = o.order_id 
												  WHERE o.order_id = OLD.order_id);
-- Q#16
CREATE TRIGGER adding_staffs_manger_full 
BEFORE UPDATE ON staffs  
FOR EACH ROW 
BEGIN 
	DECLARE manager_staff_count INT; 
	
	IF OLD.manager_id <> NEW.manager_id THEN 
		SELECT COUNT(s1.staff_id) INTO manager_staff_count  
		FROM staffs s1  
		JOIN staffs s2 
			ON s1.manager_id = s2.staff_id  
		WHERE s2.staff_id = NEW.manager_id 
		GROUP BY s1.manager_id; 

		IF manager_staff_count > 1 THEN  
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error:Specific manager is full!'; 
		END IF; 
	END IF; 
END;

-- Q#17
CREATE TRIGGER customer_phone_check_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    IF NOT NEW.phone REGEXP '^[0-9]{7,15}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error:Phone number must have between 7 and 15 digits!';
    END IF;
END;

