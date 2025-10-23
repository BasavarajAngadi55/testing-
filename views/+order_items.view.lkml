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

# Filter for user to select the MTD/QTD end date
  filter: mtd_anchor_date {
    type: date
    label: "MTD/QTD End Date Selector"
    description: "Select a date to calculate MTD, QTD, WTD, and YTD totals up to this date"
  }

# Dynamic MTD measure for total sales up to the selected date
  measure: total_sales_mtd_dynamic {
    type: sum
    sql:
    CASE
      WHEN
        DATE_TRUNC(DATE(${TABLE}.created_at), MONTH) = DATE_TRUNC(
          DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP())), MONTH)
        AND DATE(${TABLE}.created_at) <= DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP()))
      THEN ${sale_price}
      ELSE 0
    END ;;
    value_format_name: usd_0
    label: "Total Sales (MTD Dynamic)"
    description: "MTD total sales based on the selected end date or today if not selected"
  }

# Dynamic QTD measure for total sales up to the selected date
  measure: total_sales_qtd_dynamic {
    type: sum
    sql:
    CASE
      WHEN
        DATE_TRUNC(DATE(${TABLE}.created_at), QUARTER) = DATE_TRUNC(
          DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP())), QUARTER)
        AND DATE(${TABLE}.created_at) <= DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP()))
      THEN ${sale_price}
      ELSE 0
    END ;;
    value_format_name: usd_0
    label: "Total Sales (QTD Dynamic)"
    description: "QTD total sales based on the selected end date or today if not selected"
  }

# Dynamic WTD measure for total sales up to the selected date
  measure: total_sales_wtd_dynamic {
    type: sum
    sql:
    CASE
      WHEN
        DATE_TRUNC(DATE(${TABLE}.created_at), WEEK(MONDAY)) = DATE_TRUNC(
          DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP())), WEEK(MONDAY))
        AND DATE(${TABLE}.created_at) <= DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP()))
      THEN ${sale_price}
      ELSE 0
    END ;;
    value_format_name: usd_0
    label: "Total Sales (WTD Dynamic)"
    description: "WTD total sales based on the selected end date or today if not selected"
  }

# Dynamic YTD measure for total sales up to the selected date
  measure: total_sales_ytd_dynamic {
    type: sum
    sql:
    CASE
      WHEN
        DATE_TRUNC(DATE(${TABLE}.created_at), YEAR) = DATE_TRUNC(
          DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP())), YEAR)
        AND DATE(${TABLE}.created_at) <= DATE(COALESCE({% date_end mtd_anchor_date %}, CURRENT_TIMESTAMP()))
      THEN ${sale_price}
      ELSE 0
    END ;;
    value_format_name: usd_0
    label: "Total Sales (YTD Dynamic)"
    description: "YTD total sales based on the selected end date or today if not selected"
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

  # Dynamic sales measure (fixed types: cast created_at to DATE for comparisons)
  measure: dynamic_sales {
    type: sum
    sql:
      CASE
        WHEN
          {% if metric_selector._parameter_value == 'mtd' %}
            DATE_TRUNC(DATE(${TABLE}.created_at), MONTH) = DATE_TRUNC(COALESCE({% date_end global_date_filter %}, CURRENT_DATE()), MONTH)
            AND DATE(${TABLE}.created_at) <= COALESCE({% date_end global_date_filter %}, CURRENT_DATE())
          {% elsif metric_selector._parameter_value == 'qtd' %}
            DATE_TRUNC(DATE(${TABLE}.created_at), QUARTER) = DATE_TRUNC(COALESCE({% date_end global_date_filter %}, CURRENT_DATE()), QUARTER)
            AND DATE(${TABLE}.created_at) <= COALESCE({% date_end global_date_filter %}, CURRENT_DATE())
          {% elsif metric_selector._parameter_value == 'ytd' %}
            EXTRACT(YEAR FROM ${TABLE}.created_at) = EXTRACT(YEAR FROM COALESCE({% date_end global_date_filter %}, CURRENT_DATE()))
            AND DATE(${TABLE}.created_at) <= COALESCE({% date_end global_date_filter %}, CURRENT_DATE())
          {% endif %}
        THEN ${sale_price}
        ELSE 0
      END
    ;;
    value_format_name: usd
    description: "Sale price for selected period up to global date filter end (defaults to today: Oct 23, 2025)"
  }

  }
