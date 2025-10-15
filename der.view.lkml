# If necessary, uncomment the line below to include explore_source.
# include: "testing-b.model.lkml"

view: test {
  derived_table: {
    explore_source: order_items {
      column: category { field: products.category }
      column: sale_price {}
    }
  }
  dimension: category {
    description: ""
  }
  dimension: sale_price {
    description: ""
    type: number
  }
}
