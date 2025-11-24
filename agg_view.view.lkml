# If necessary, uncomment the line below to include explore_source.
# include: "testing-b.model.lkml"

view: agg_table {
  derived_table: {
    explore_source: order_items {
      column: created_month {}
      column: total_sale_price {}
    }
  }
  dimension: created_month {
    description: ""
    type: date_month
  }
  dimension: total_sale_price {
    description: ""
    value_format: "$#,##0"
    type: number
  }
}
