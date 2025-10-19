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


# Dynamic MTD measure using CURRENT_DATE() in IST
  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
      CASE
        WHEN
          -- 1. Ensure the order date is in the same month as the current date
          DATE_TRUNC(${created_date}, MONTH) = DATE_TRUNC(CURRENT_DATE('Asia/Kolkata'), MONTH)
          -- 2. Ensure the order date is on or before the current date
          AND ${created_date} <= CURRENT_DATE('Asia/Kolkata')
        THEN ${sale_price}
        ELSE 0
      END ;;
    value_format_name: usd_0
  }


  }
