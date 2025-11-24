view: agg_table {
  derived_table: {
    # Looker will build this table dynamically
    sql:
      SELECT
        FORMAT_TIMESTAMP('%Y-%m', order_items.created_at) AS order_items_created_month,
        COALESCE(SUM(order_items.sale_price), 0) AS order_items_total_sale_price
      FROM `order_items` AS order_items
      GROUP BY 1
      ORDER BY 1 DESC
      LIMIT 500 ;;
    # Optionally, use persistence if you want to cache results
    # persist_for: "24 hours"
    }

    dimension: created_month {
      type: string
      sql: ${TABLE}.order_items_created_month ;;
    }

    measure: total_sale_price {
      type: sum
      sql: ${TABLE}.order_items_total_sale_price ;;
    }
  }
