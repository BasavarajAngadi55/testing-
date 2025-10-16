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


# 1. This filter field is what the user interacts with in the Explore
  filter: date_anchor {
    type: date
    # Always filter on this in the Explore (e.g., set to 'yesterday')
    # but allow the user to change it to any date.
  }

# 2. This helper dimension captures the last date the user selected in the filter
# We use this as the "Today" for our MTD calculation.
  dimension: current_anchor_date {
    type: date
    hidden: yes
    sql: {% date_end date_anchor %} ;;
  }

# This will flag all rows that belong to the MTD period,
# based on the day number of the anchor date.
  dimension: is_current_mtd {
    type: yesno
    sql:
          DATE_TRUNC('month', ${created_date}) = DATE_TRUNC('month', CURRENT_DATE())
          AND EXTRACT(DAY FROM ${created_date}) <= EXTRACT(DAY FROM CURRENT_DATE())
        ;;
  }

  measure: total_sales_mtd_today {
    type: sum
    sql: ${sale_price} ;;
    filters: {
      field: is_current_mtd
      value: "yes"
    }
    value_format_name: usd_0
  }








}
