# Define server logic
server <- function(input, output) {
  
  
  #### Overview Page ####
  output$overview_value_boxes <- renderUI({
    fluidRow(
      valueBox(
        value=networth_var,
        # value=1000,
        "Net Worth",
        icon=icon("coins"),
        color="aqua",
        # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
        width=4
      ),
      valueBox(
        value=ytd_income_var,
        "YTD Income",
        icon=icon("file-invoice"),
        color="light-blue",
        width=4
      ),
      valueBox(
        # value="Rent & Food and Drinks",
        value=ytd_spend_var,
        "YTD Spending",
        icon=icon("chart-pie"),
        color="teal",
        width=4
      )
    )
  })
  
  #### Budget Page ####
  month_spend_var <- reactive({
    year_from_var <- input$budget_spend_year
    month_from_var <- input$budget_spend_month
    year_month_var <- paste0(as.character(year_from_var), "_", sprintf("%02d", as.numeric(month_from_var)))
    
    month_spend_var <- spend_data %>%
      filter(year_month==year_month_var) %>%
      pull(amount) %>%
      sum()
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
      mutate(shade_color=if_else(amount_left<0, "#DC3D4B", "#5BBDC8")) %>%
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
    # spend_trend_df <- filtered_spend_df %>%
    spend_trend_df <- filtered_spend_df() %>%
      filter(is.null(input$spend_category) | category %in% input$spend_category) %>%
      group_by(year_month, year, month) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      arrange(year_month)
    
    xaxis_labels_df <- spend_trend_df %>%
      group_by(year) %>%
      summarize(min_month=min(month)) %>%
      ungroup() %>%
      mutate(xaxis_tick_label1=paste0(month.abb[min_month], "<br>", as.character(year)))
    
    spend_trend_df2 <- spend_trend_df %>%
      merge(xaxis_labels_df, by.x=c("year", "month"), by.y=c("year", "min_month"), all.x=T) %>%
      mutate(xaxis_tick_label=if_else(is.na(xaxis_tick_label1), paste0(month.abb[month]), xaxis_tick_label1)) %>%
      mutate(xaxis_hover_label=paste0(month.abb[month], " ", as.character(year)))
  })
  
  output$spend_trend_chart <- renderPlotly({
    spend_trend_df <- spend_trend_df()
    
    fig <- spend_trend_df %>%
      plot_ly(
        x=~xaxis_hover_label,
        y=~amount,
        customdata=spend_trend_df$xaxis_hover_label,
        hovertemplate=" %{customdata} <br> <b>%{y}</b> <extra></extra>",
        type="bar"
      ) %>%
      layout(
        xaxis=list(title="",
                   tickmode="array", # to manually set the tick values on x axis
                   tickvals=~xaxis_hover_label,
                   ticktext=~xaxis_tick_label,
                   zeroline=F),
        yaxis=list(title="",
                   zeroline=F,
                   showgrid=F,
                   tickprefix="$ ",
                   tickformat=",d",
                   font=list(size=14)),
        bargap=0.3,
        hoverlabel=list(bgcolor="white",
                        font=list(size=14))
      )
    fig
  })
  
  # Spend - By Category Chart
  spend_category_df <- reactive({
    spend_category_df <- filtered_spend_df() %>%
      filter(is.null(input$spend_category) | category %in% input$spend_category) %>%
      group_by(category) %>%
      summarize(across(c("amount"), ~sum(.x, na.rm=T))) %>%
      ungroup() %>%
      # mutate(ticktext=paste0("$ ", formatC(amount, format="f",big.mark=",",digits=0))) %>%
      arrange(-amount)
      # mutate(shade_color=if_else(amount_left<0, "#DC3D4B", "#5BBDC8"))
  })
  
  
  output$spend_category_chart <- renderPlotly({
    spend_category_df <- spend_category_df()
    
    colors_list <- c("#2B86BB", "#348ABC","#3C8DBC","#4491BD","#4E95BE","#5698BE","#5F9BBE","#689EBE","#70A1BE","#79A4BE","#89AABE","#91AEBF","#9AB2C1", "#9FB4C1", "#A6B7C2")
    
    fig <- spend_category_df %>%
      arrange(-amount) %>%
      plot_ly(
        x=~amount,
        y=~reorder(category, amount),
        type="bar",
        orientation="h",
        marker=list(color=~colors_list),
        hovertemplate=" %{y} <br> <b>%{x}</b> <extra></extra>"
      ) %>%
      layout(
        xaxis=list(title="",
                   zeroline=F,
                   tickprefix="$",
                   tickformat=",d"),
        yaxis=list(title="",
                   showgrid=F,
                   showline=F,
                   zeroline=F,
                   tickfont=list(size=14),
                   ticksuffix="  "),
        bargap=0.3,
        hoverlabel=list(bgcolor="white",
                        font=list(size=14))
      )
    fig
  })
  
  
  # Spend - Summary Boxes
  output$spend_summary_text <- renderUI({
    # total_spend_var <- formatC(sum(spend_trend_df()$amount), format="f", big.mark=",", digits=0)
    # avg_monthly_spend_var <- formatC(sum(spend_trend_df()$amount)/nrow(spend_trend_df()), format="f", big.mark=",", digits=0)

    str1 <- paste("From ", month.abb[as.numeric(input$spend_month_from)], " ", input$spend_year_from,
                  " to ", month.abb[as.numeric(input$spend_month_to)], " ", input$spend_year_to, ":<br>")
    # str2 <- paste("<p style='font-size:20px;'><b>$ ", total_spend_var, "</b> Total Spend</p>")
    # str3 <- paste("<p style='font-size:20px;'><b>$ ", avg_monthly_spend_var, "</b> Average Monthly Spend: </p>")

    HTML(str1)
    # HTML(paste(str1, str2, str3, sep = '<br/>'))
    # HTML(paste0("<p style='font-size:34px;'>",
    #   paste(str1, str2, str3, sep = "<br/>"),
    #   "</p>")
    # )
  })
  
  output$spend_summary_info <- renderUI({
    total_spend_var <- paste("$ ", formatC(sum(spend_trend_df()$amount), format="f", big.mark=",", digits=0))
    avg_monthly_spend_var <- paste("$ ", formatC(sum(spend_trend_df()$amount)/nrow(spend_trend_df()), format="f", big.mark=",", digits=0))
    
    fluidRow(
      column(12,
             infoBox(
               title="Total Spend",
               value=total_spend_var,
               icon=icon("coins"),
               color="aqua",
               width=12
             )),
      column(12,
             infoBox(
               title="Average Monthly Spend",
               value=avg_monthly_spend_var,
               icon=icon("coins"),
               color="aqua",
               width=12
             ))
    )
  })
  
  
}

## Run the application 
# shinyApp(ui = ui, server = server)
