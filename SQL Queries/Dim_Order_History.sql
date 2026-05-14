SELECT history_id,order_id,order_history.status_id,status_date,status_value
FROM ORDER_HISTORY
LEFT JOIN order_status
ON order_status.status_id = order_history.status_id