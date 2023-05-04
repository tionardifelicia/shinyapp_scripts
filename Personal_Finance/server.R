# Define server logic
server <- function(input, output) {
  
  # Chart 1
  output$chart1 <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) + 
      geom_point()
  })
  
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
  
}

## Run the application 
# shinyApp(ui = ui, server = server)
