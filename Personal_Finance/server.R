# Define server logic
server <- function(input, output) {
  
  #### Overview Page ####
  # Chart 1
  output$chart1 <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) + 
      geom_point()
  })
  
  #### Budget Page ####
  # Budget Table
  output$budget_table <- DT::renderDataTable({
    DT::datatable(budget_raw_data, options = list(pageLength = 10))
  })
  
  # Budget Pie Chart
  output$budget_chart <- renderPlotly({
    budget_df <- budget_raw_data
    
    fig <- plot_ly(
      labels=budget_df$category,
      values=budget_df$amount,
      type='pie'
    )
  })
  
  #### Spending Page ####
  
  # Spend Value Boxes
  output$spend_value_boxes <- renderUI({
      fluidRow(
        valueBox(
          value=mtd_spend_var,
          # value=1000,
          "MTD Spending",
          icon=icon("coins"),
          color="aqua",
          # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
          width=4
        ),
        valueBox(
          value=ytd_spend_var,
          "YTD Spending",
          icon=icon("file-invoice"),
          color="light-blue",
          width=4
        ),
        valueBox(
          # value="Rent & Food and Drinks",
          value=mtd_top_spend_var,
          "Top MTD Spending Category",
          icon=icon("chart-pie"),
          color="teal",
          width=4
        )
      )
  })
  
  output$spend_value_boxes2 <- renderUI({
    output$spend_value_boxes
  })
  output$spend_value_boxes2 <- renderUI({
    fluidRow(
      valueBox(
        value=mtd_spend_var,
        # value=1000,
        "MTD Spending",
        icon=icon("coins"),
        color="aqua",
        # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
        width=4
      ),
      valueBox(
        value=ytd_spend_var,
        "YTD Spending",
        icon=icon("file-invoice"),
        color="light-blue",
        width=4
      ),
      valueBox(
        # value="Rent & Food and Drinks",
        value=mtd_top_spend_var,
        "Top MTD Spending Category",
        icon=icon("chart-pie"),
        color="teal",
        width=4
      )
    )
  })
  
}

## Run the application 
# shinyApp(ui = ui, server = server)
