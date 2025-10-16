include: "/views/order_items.view"

view: +order_items {
  measure: Avg_Sales_price {
    type: average
    # This is correct because it references the dimension: sale_price above
    sql: ${sale_price} ;;
  }
}
