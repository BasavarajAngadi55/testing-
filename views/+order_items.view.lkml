include: "/views/order_items.view"

view: +order_items {
  measure: total_sale_price {
    type: sum
    sql: ${order_items.sale_price} ;;
    value_format_name: usd_0
  }

  measure: LastYearSales {
    type: period_over_period
    based_on: total_sale_price  # <-- This field must be a valid aggregate measure
    based_on_time: created_year
    period: year
    kind: previous
    value_format_name: usd_0
  }

# Dynamic MTD measure using the selected created_date context
  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
      CASE
        WHEN
          -- 1. Ensure the order date is in the same month as the maximum selected date in context
          DATE_TRUNC(${created_date}, MONTH) = (
            SELECT DATE_TRUNC(MAX(created_at), MONTH)
            FROM `thelook.order_items`
            WHERE created_at <= MAX(${created_date})
          )
          -- 2. Ensure the order date is on or before the maximum selected date in context
          AND ${created_date} <= MAX(${created_date})
        THEN ${sale_price}
        ELSE 0
      END ;;
    value_format_name: usd_0
  }

  }
