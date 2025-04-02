
select
    orders.*,
    order_item_summary.gross_item_sales_amount,
    order_item_summary.item_discount_amount
from
    dbt_db.dbt_schema.stg_tpch_orders as orders
join
    dbt_db.dbt_schema.int_order_items_summary as order_item_summary
        on orders.order_key = order_item_summary.order_key
order by order_date