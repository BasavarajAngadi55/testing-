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

# Filter for user to select the MTD end date
  filter: mtd_anchor_date {
    type: date
    label: "MTD End Date Selector"
  }
# Helper dimension to capture the selected end date
  dimension: current_anchor_date {
    type: date
    hidden: yes
    sql: {% date_end mtd_anchor_date %} ;;
  }

# Dynamic MTD measure for total sales up to the selected date
  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
      CASE
        WHEN
          -- 1. Ensure the order date is in the same month as the selected date
          DATE_TRUNC(${TABLE}.created_date, MONTH) = DATE_TRUNC({% date_end mtd_anchor_date %}, MONTH)
          -- 2. Ensure the order date is on or before the selected date
          AND ${TABLE}.created_date <= {% date_end mtd_anchor_date %}
        THEN ${sale_price}
        ELSE 0
      END ;;
    value_format_name: usd_0
  }




  }
