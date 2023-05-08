library(shiny)
library(shinydashboard)
library(ggplot2)

# Define UI for the application
ui <- dashboardPage(
  dashboardHeader(title="Personal Finance Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(" Overview", tabName="overview_page", icon=icon("display")),
      menuItem(" Budget", tabName="budget_page", icon=icon("chart-pie")),
      menuItem(" Spending", tabName="spend_page", icon=icon("receipt")),
      menuItem(" About", tabName="about_page", icon=icon("circle-info"))
    )
  ),
  
  dashboardBody(
    
    tabItems(
      tabItem(
        tabName="overview_page",
        uiOutput('overview_value_boxes'),
        fluidRow(
          column(4,
                 box(
                   title="Assets",
                   status="primary",
                   solidHeader=F,
                   height="600px",
                   width=12,
                   column(7),
                   column(5, selectInput("view_asset_options", "", c("By Account Name"="account", "By Account Type"="account_type"))),
                   dataTableOutput("asset_dt")
                   )
          ),
          column(8,
                 box(
                   title="",
                   status="primary",
                   solidHeader=F,
                   height="600px",
                   width=12,
                   tabsetPanel(
                     tabPanel(
                       "Net Worth", 
                       fluidRow(
                         column(3, selectInput("networth_chart_options", "", c("Last Six Months", "Last Year", "All Time"), selected="All Time", multiple=F)),
                         column(9)),
                       plotlyOutput("networth_chart")),
                     tabPanel(
                       "Income vs Spending", 
                       fluidRow(
                         column(3, selectInput("income_vs_spend_options", "", c("Last Six Months", "Last Year", "All Time"), selected="All Time", multiple=F)),
                         column(9)),
                       plotlyOutput("income_vs_spend_chart"))
                   
                   )
                 )
          )
        )
      ),
      
      tabItem(
        tabName="budget_page",
        fluidRow(
          column(3,
            uiOutput("budget_value_boxes")
          ),
          box(
            # title="Monthly Budget vs Monthly Spending",
            status="info",
            solidHeader=F,
            width=9,
            height="650px",
            # DT::dataTableOutput("budget_table")
            fluidRow(
              column(6),
              column(3, selectizeInput("budget_spend_month", "Spend Month", input_month_vars, current_month, multiple=F)),
              column(3, selectInput("budget_spend_year", "Spend Year", unique(spend_raw_data$year), current_year, multiple=F))
            ),
            plotlyOutput("budget_vs_spend_chart"),
            HTML("<i>*Hover around the chart to see how much was spent and how much was left over from budget.</i>")
          ),
          
        )
      ),
      
      
      tabItem(
        tabName="spend_page",
        uiOutput("spend_value_boxes"),
        fluidRow(
          box(title="Over Time", status="primary", solidHeader=F, width=6, height="500px",
                     plotlyOutput("spend_trend_chart")),
          box(title="By Category", status="primary", solidHeader=F, width=6, height="500px",
                     plotlyOutput("spend_category_chart"))
        ),
        fluidRow(
          column(9,
                 box(title="Chart Configurations", status="info",
                     width=12,
                      column(3, selectizeInput("spend_month_from", "From: Month", input_month_vars, current_month, multiple=F)),
                      column(3, selectInput("spend_year_from", "Year", unique(spend_raw_data$year), current_year, multiple=F)),
                      column(3, selectInput("spend_month_to", "To: Month", input_month_vars, current_month, multiple=F)),
                      column(3, selectizeInput("spend_year_to", "Year", unique(spend_raw_data$year), current_year, multiple=F)),
                      
                      column(6, selectizeInput("spend_category", "Categories:", c("All"= "", budget_raw_data$category), "", multiple=T)),
                      column(6)
              )
          ),
          column(3, 
                 htmlOutput("spend_summary_text"),
                 uiOutput("spend_summary_info"))
          
          # box(title="Summary", status="info", width=3,
          #     # htmlOutput("spend_summary_text")
          #     )
        )
      ),
      
      tabItem(
        tabName="about_page",
        h2("About This Dashboard"),
        h5("Personal Finance dashboard is an interactive Shiny dashboard built to track overall personal finance.")
        # h6("May 3, 2023")
      )
    )

  )
)

