include: "/views/order_items.view"

view: +order_items {
  measure: Avg_Sales_price {
    type: average
    # CORRECT WAY: Refer to the dimension within the current view
    sql: ${sale_price} ;;
  }
}
