
include: "/views/order_items.view"

view: +order_items{
measure:Avg_Sales_price {
type: average
sql: ${order_items.sale_price};;

}
}
