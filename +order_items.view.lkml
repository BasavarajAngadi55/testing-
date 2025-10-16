view: +order_items{
measure:Avg_Sales_price {
type: average
sql: ${order_items.sale_price};;
drill_fields: [inventory_items.product_brand]
}
}
