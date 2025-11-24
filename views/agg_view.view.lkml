view: agg_table {
  # This uses a Native Derived Table (NDT) via explore_source
  derived_table: {
    # The 'explore_source' runs a query against the 'order_items' explore
    explore_source: order_items {
      # The dimensions (GROUP BY)
      column: created_month {}

      # The measure (aggregation)
      column: total_sale_price { field: order_items.total_sale_price }
      # NOTE: It's best practice to explicitly reference the original field here.
    }
  }

  # --- Dimensions (GROUP BY columns) ---
  dimension_group: created {
    type: time
    timeframes: [month]
    sql: ${created_month} ;; # This refers to the column from the explore_source
  }

  # --- Measures (Aggregated results from the explore_source) ---
  measure: total_monthly_sale {
    description: "Total sales aggregated monthly (from the NDT)."
    type: sum
    sql: ${order_items.total_sale_price} ;; # SUM the pre-aggregated monthly total
    value_format: "$#,##0"
  }
}
