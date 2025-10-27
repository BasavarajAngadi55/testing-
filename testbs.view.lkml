# If necessary, uncomment the line below to include explore_source.
# include: "testing-b.model.lkml"

view: testb{
  derived_table: {
    explore_source: order_items {
      column: brand { field: products.brand }
      column: total_cost {}
    }
  }
  dimension: brand {
    description: ""
  }
  dimension: total_cost {
    description: "Calculates the total cost of inventory items."
    type: number
  }
}
