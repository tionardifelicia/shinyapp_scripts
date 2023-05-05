# Define server logic
server <- function(input, output) {
  
  
  #### Overview Page ####
  # Chart 1
  output$chart1 <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) + 
      geom_point()
  })
  
  
  #### Budget Page ####
  month_spend_var <- reactive({
    year_from_var <- input$budget_spend_year
    month_from_var <- input$budget_spend_month
    year_month_var <- paste0(as.character(year_from_var), "_", sprintf("%02d", as.numeric(month_from_var)))
    
    print('0')
    print(year_from_var)
    print(year_month_var)
    
    month_spend_var <- spend_data %>%
      filter(year_month==year_month_var) %>%
      pull(amount) %>%
      sum()
    print('1')
    print(month_spend_var)
    month_spend_var
  })
  
  leftover_var <- reactive({
    leftover_var <- budget_var-month_spend_var()
  })
  
  # Budget - Value Boxes
  output$budget_value_boxes <- renderUI({
    #          # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
    
    budget_var <- paste("$",
                          formatC(
                            budget_var,
                            format="f",
                            big.mark=",",
                            digits=0))
    
    month_spend_var <- paste("$",
                             formatC(
                               month_spend_var(),
                               format="f",
                               big.mark=",",
                               digits=0))
    
    leftover_var <- paste("$",
                        formatC(
                          leftover_var(),
                          format="f",
                          big.mark=",",
                          digits=0))
    
    fluidRow(
      column(12,
             valueBox(
               value=budget_var,
               "Budget",
               icon=icon("comment-dollar"),
               color="green",
               width=12
             )
      ),
      column(12,
             valueBox(
               value=month_spend_var,
               "Spending",
               icon=icon("file-invoice"),
               color="teal",
               width=12
             )
      ),
      column(12,
             valueBox(
               # value="Rent & Food and Drinks",
               value=leftover_var,
               "Left Over",
               icon=icon("wallet"),
               color="yellow",
               width=12
               )
             )
      )
  })
  
  
  
  # Budget - Monthly Budget vs Monthly Spending Chart
  output$budget_vs_spend_chart <- renderPlotly({
    year_from_var <- input$budget_spend_year
    month_from_var <- input$budget_spend_month
    year_month_var <- paste0(as.character(year_from_var), "_", sprintf("%02d", as.numeric(month_from_var)))
    
    monthly_spend_df <- spend_data %>%
      filter(year_month==year_month_var) %>%
      # filter(year_month=="2023_02") %>%
      group_by(category) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      rename("spend_amount"="amount")
    
    # monthly_spend_df
    # budget_raw_data
    
    budget_vs_spend_df <- budget_raw_data %>%
      rename("budget_amount"="amount") %>%
      merge(monthly_spend_df, by="category", all.x=T) %>%
      replace_na(list(spend_amount=0)) %>%
      mutate(amount_left=budget_amount-spend_amount) %>%
      arrange(-budget_amount)
    
    # red shade if over budget, green shade if still has leftover budget
    budget_vs_spend_df2 <- budget_vs_spend_df %>%
      mutate(shade_pct=if_else(spend_amount>=budget_amount,1,(spend_amount)/budget_amount)) %>% #shade_pct: spend pct
      mutate(no_shade_pct=1-shade_pct) %>% #no_shade_pct: leftover budget pct
      mutate(shade_color=if_else(shade_pct>=1, "#DC3D4B", "#5BBDC8")) %>%
      arrange(-budget_amount)
    
    fig <- budget_vs_spend_df2 %>%
      plot_ly(x=~shade_pct, y=~reorder(category, budget_amount), type="bar", orientation="h",
              marker=list(color=~shade_color)) %>%
      add_trace(x=~no_shade_pct, y=~reorder(category, budget_amount), type="bar", orientation="h",
                marker=list(color='#E1EAEB'),
                text=~budget_amount, textposition="outside", textfont=list(size=14)) %>%
      layout(
        margin=list(l=100,r=100),
        yaxis=list(title="",
                   showgrid=F,
                   showline=F,
                   zeroline=F,
                   tickfont=list(size=14),
                   ticksuffix="  "
                   ),
        xaxis=list(title="",
                   showgrid=F,
                   showline=F,
                   zeroline=F,
                   showticklabels=F),
        showlegend=F,
        bargap=0.5,
        barmode="stack"
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
    # %>%
    #   mutate(width=0.8)
    
    # print('1')
    # print(head(spend_trend_df))
    
    fig <- spend_trend_df %>%
      plot_ly(
        x=~year_month,
        y=~amount
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
