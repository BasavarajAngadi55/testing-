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


# This is the filter the user selects in the Explore (e.g., 'is before 2025-10-16')
  filter: mtd_anchor_date {
    type: date
    label: "MTD End Date Selector"
  }

# 2. This helper dimension captures the last date the user selected in the filter
# We use this as the "Today" for our MTD calculation.
  dimension: current_anchor_date {
    type: date
    hidden: yes
    sql: {% date_end date_anchor %} ;;
  }

  dimension: is_current_mtd {
    type: yesno
    sql: DATE_TRUNC(${created_date}, MONTH) = DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND EXTRACT(DAY FROM ${created_date}) <= EXTRACT(DAY FROM CURRENT_DATE()) ;;
  }

  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
    SUM(
      CASE
        WHEN
          -- 1. Date is in the same month as the end date of the filter:
          DATE_TRUNC('month', ${created_date}) = DATE_TRUNC('month', DATE({% date_end mtd_anchor_date %}))
          -- 2. Date is less than or equal to the end date of the filter:
          AND ${created_date} <= DATE({% date_end mtd_anchor_date %})
        THEN ${sale_price}
        ELSE NULL
      END
    )
  ;;
    value_format_name: usd_0
  }
  }
