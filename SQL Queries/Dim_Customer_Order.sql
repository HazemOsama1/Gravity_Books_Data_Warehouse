SELECT order_id, order_date, customer_id,dest_address_id,
		method_id, method_name, cost
FROM cust_order C
LEFT JOIN shipping_method S 
ON S.method_id = C.shipping_method_id