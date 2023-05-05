# Define server logic
server <- function(input, output) {
  
  
  #### Overview Page ####
  # Chart 1
  output$chart1 <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) + 
      geom_point()
  })
  
  
  #### Budget Page ####
  # # Budget Table
  # output$budget_table <- DT::renderDataTable({
  #   DT::datatable(budget_raw_data, options = list(pageLength = 15))
  # })
  
  # Budget Pie Chart
  output$budget_chart <- renderPlotly({
    budget_df <- budget_raw_data
    
    fig <- plot_ly(
      labels=budget_df$category,
      values=budget_df$amount,
      type="pie",
      hole=0.5) %>%
      add_pie(
        hoverinfo="label+value+percent",
        hovertemplate="%{label} \n %{value} (%{percent})"
      ) %>%
      layout(
        showlegend=F,
        width=500,
        height=500
        )
  })
  
  # Budget - Monthly Budget vs Monthly Spending Chart
  output$budget_vs_spend_chart <- renderPlotly({
    monthly_spend_df <- spend_data %>%
      filter(year==2023, month==4) %>%
      group_by(category) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      rename("spend_amount"="amount")
    
    monthly_spend_df
    budget_raw_data
    
    budget_vs_spend_df <- budget_raw_data %>%
      merge(monthly_spend_df, by="category", all.x=T) %>%
      arrange(-amount)
    
    fig <- budget_vs_spend_df %>%
      plot_ly(
        x=~spend_amount,
        y=~reorder(category, spend_amount),
        type="bar",
        orientation="h"
    ) %>% 
      add_trace(
        x=~budget_vs_spend_df$amount,
        y=~reorder(budget_vs_spend_df$category, budget_vs_spend_df$amount),
        type="bar",
        orientation="h"
        ) %>%
      add_trace(
        text=~paste0("$", amount-spend_amount),
        textposition="outside"
      ) %>%
      layout(
        barmode="overlay",
        xaxis=list(title=""),
        yaxis=list(title="")
        )
    fig
    
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
  
  filtered_spend_df <- reactive({
    year_from_var <- input$spend_year_from
    month_from_var <- input$spend_month_from
    year_month_from <- paste0(as.character(year_from_var), "_", sprintf("%02d", as.numeric(month_from_var)))
    
    year_to_var <- input$spend_year_to
    month_to_var <- input$spend_month_to
    year_month_to <- paste0(as.character(year_to_var), "_", sprintf("%02d", as.numeric(month_to_var)))
    
    filtered_spend_df <- spend_data %>%
      filter(year_month>=year_month_from, year_month<=year_month_to)
  })
  
  
  # Spend - Over Time Chart
  spend_trend_df <- reactive({
    spend_trend_df <- filtered_spend_df() %>%
      filter(is.null(input$spend_category) | category %in% input$spend_category) %>%
      group_by(year_month) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      arrange(year_month)
    
  })
  
  output$spend_trend_chart <- renderPlotly({
    spend_trend_df <- spend_trend_df() 
    
    fig <- spend_trend_df %>%
      plot_ly(
        x=~year_month,
        y=~amount,
        type="bar"
      ) %>%
      layout(
        xaxis=list(title=""),
        yaxis=list(title="")
      )
  })
  
  # Spend - By Category Chart
  spend_category_df <- reactive({
    spend_category_df <- filtered_spend_df() %>%
      filter(is.null(input$spend_category) | category %in% input$spend_category) %>%
      group_by(category) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      arrange(-amount)
  })
  
  
  output$spend_category_chart <- renderPlotly({
    spend_category_df <- spend_category_df()
    
    fig <- spend_category_df %>%
      arrange(-amount) %>%
      plot_ly(
        x=~amount,
        y=~reorder(category, amount),
        type="bar",
        orientation="h"
      ) %>%
      layout(
        xaxis=list(title=""),
        yaxis=list(title="")
      )
  })
  
  
  
}

## Run the application 
# shinyApp(ui = ui, server = server)
