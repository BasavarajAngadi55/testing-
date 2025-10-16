include: "/views/order_items.view"

view: +order_items {
  measure: total_sale_price {
    type: sum
    sql: ${order_items.sale_price} ;;
    value_format_name: usd_0
  }

measure: LastYearSales {
type: period_over_period
sql: ${order_items.sale_price};;
period: year
kind: previous
value_format_name: usd_0
based_on: sale_price
based_on_time: created_year

}

}
