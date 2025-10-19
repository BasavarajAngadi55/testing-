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




  measure: total_sales_mtd_dynamic_1 {
    type: sum
    sql:
    CASE
      WHEN DATE_TRUNC(${TABLE}.created_at, MONTH) = DATE_TRUNC(${TABLE}.created_at, MONTH)
      THEN ${sale_price}
      ELSE 0
    END ;;
  }


  }
