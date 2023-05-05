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
  
  # Spend - Over Time Chart
  output$spend_trend_chart <- renderPlotly({
    fig <- plot_ly(
      labels=mtcars$mpg,
      values=mtcars$wt,
      type='pie'
    )
  })
  
  # Spend - By Category Chart
  spend_category_df <- reactive({
    year_from_var <- input$spend_year_from
    month_from_var <- input$spend_month_from
    year_month_from <- paste0(as.character(year_from_var), sprintf("%02d", as.numeric(month_from_var)))
    print('0a')
    print(year_month_from)
    
    year_to_var <- input$spend_year_to
    month_to_var <- input$spend_month_to
    year_month_to <- paste0(as.character(year_to_var), sprintf("%02d", as.numeric(month_to_var)))
    print('0b')
    print(year_month_to)
    
    spend_df <- spend_data %>%
      filter(year_month>=year_month_from, year_month<=year_month_to) %>%
      group_by(category) %>%
      summarize(across(c('amount'), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      arrange(-amount)
  })
  
  
  output$spend_category_chart <- renderPlotly({
    spend_category_df <- spend_category_df()
    # spend_category_df <- spend_df
    print('1')
    print(head(spend_category_df))
    
    ## ggplot
    # fig <- spend_category_df %>%
    #   ggplot(aes(x=reorder(category, amount), y=amount)) +
    #   geom_col(fill="grey") +
    #   labs(x="Category", y="Spending Amount") +
    #   coord_flip() +
    #   theme_bw()
    # 
    # fig
    
    ##plotly
    fig <- spend_category_df %>%
      arrange(-amount) %>%
      plot_ly(
        x=~amount,
        y=~category,
        type="bar",
        orientation="h"
      ) %>%
      layout(
        xaxis=list(title="Spending Amount"),
        yaxis=list(title="Category")
      )
    
    fig
    
    
  })
  
  
  
}

## Run the application 
# shinyApp(ui = ui, server = server)
