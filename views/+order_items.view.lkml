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


  # Dynamic MTD measure for total sales up to the selected date
  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
      CASE
        WHEN
          DATE_TRUNC(${TABLE}.created_at, MONTH) = DATE_TRUNC({% date_end mtd_anchor_date %}, MONTH)
          AND ${TABLE}.created_at <= {% date_end mtd_anchor_date %}
        THEN ${sale_price}
        ELSE 0
      END ;;
    value_format_name: usd_0
  }

# Global date filter (users pick range here—e.g., Oct 1-23, 2025)
  filter: global_date_filter {
    type: date
    description: "Select your date range (e.g., Oct 1-23). This sets the 'up to' date for MTD/QTD/YTD."
  }
# Metric selector (dropdown for MTD, QTD, YTD)
  parameter: metric_selector {
    type: unquoted
    allowed_value: {
      label: "Month to Date (MTD)"
      value: "mtd"
    }
    allowed_value: {
      label: "Quarter to Date (QTD)"
      value: "qtd"
    }
    allowed_value: {
      label: "Year to Date (YTD)"
      value: "ytd"
    }
    default_value: "mtd"  # Starts with MTD
  }

# Dynamic sales measure (uses selector and global date filter)
  measure: dynamic_sales {
    type: number
    sql:
      SUM(
        CASE
          WHEN ${created_date} >=
            {% if metric_selector._parameter_value == 'mtd' %}
              DATE_TRUNC('month', COALESCE({% date_start global_date_filter %}, CURRENT_DATE()))
            {% elsif metric_selector._parameter_value == 'qtd' %}
              DATE_TRUNC('quarter', COALESCE({% date_start global_date_filter %}, CURRENT_DATE()))
            {% elsif metric_selector._parameter_value == 'ytd' %}
              DATE(EXTRACT(YEAR FROM COALESCE({% date_start global_date_filter %}, CURRENT_DATE())), 1, 1)
            {% endif %}
          AND ${created_date} <= COALESCE({% date_end global_date_filter %}, CURRENT_DATE())
          THEN ${sale_price}
          ELSE 0
        END
      )
    ;;
    value_format_name: usd  # Optional: Shows as $1,234
    description: "Total sale price for selected metric up to your global date range"
  }

  }
