SELECT ol.line_id
      ,ol.order_id
      ,ol.book_id
	  ,ol.price
	  ,oh.history_id
	  ,c.customer_id
	  ,co.order_date
  FROM order_line as ol
 left join
cust_order as co
on co.order_id=ol.order_id
left join
shipping_method as sm
on sm.method_id=co.shipping_method_id
left join 
order_history as oh
on co.order_id=oh.order_id
left outer join
customer as c
on c.customer_id=co.customer_id 