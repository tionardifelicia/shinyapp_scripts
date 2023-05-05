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
    # uiOutput("spend_value_boxes"),
    
    tabItems(
      tabItem(
        tabName="overview_page",
        fluidRow(
          box(
            title="Chart 1",
            status="primary",
            solidHeader=TRUE,
            width=12,
            plotOutput(outputId="chart1")
          )
        )
      ),
      
      tabItem(
        tabName="budget_page",
        fluidRow(
          box(
            title="Monthly Budget",
            status="primary",
            # background="teal",
            solidHeader=F,
            width=3,
            height="650px"
            # plotlyOutput("budget_chart")
          ),
          box(
            title="Monthly Budget vs Monthly Spending",
            status="primary",
            # background="teal",
            solidHeader=F,
            width=9,
            height="650px",
            # DT::dataTableOutput("budget_table")
            fluidRow(
              column(6),
              column(3, selectizeInput("budget_spend_month", "Spend Month", input_month_vars, current_month, multiple=F)),
              column(3, selectInput("budget_spend_year", "Spend Year", unique(spend_raw_data$year), current_year, multiple=F))
            ),
            plotlyOutput("budget_vs_spend_chart")
          ),
          
        )
      ),
      
      
      tabItem(
        tabName="spend_page",
        uiOutput("spend_value_boxes"),
        fluidRow(
          box(title="Over Time", status="primary", solidHeader=F, width=6, height="600px",
                     plotlyOutput("spend_trend_chart")),
          box(title="By Category", status="primary", solidHeader=F, width=6, height="600px",
                     plotlyOutput("spend_category_chart"))
        ),
        fluidRow(
          box(title="Charts Configurations", status="success", width=12,
              column(3, selectizeInput("spend_month_from", "From: Month", input_month_vars, current_month, multiple=F)),
              column(3, selectInput("spend_year_from", "Year", unique(spend_raw_data$year), current_year, multiple=F)),
              column(3, selectInput("spend_month_to", "To: Month", input_month_vars, current_month, multiple=F)),
              column(3, selectizeInput("spend_year_to", "Year", unique(spend_raw_data$year), current_year, multiple=F)),
              
              column(6, selectizeInput("spend_category", "Categories:", c("All"= "", budget_raw_data$category), "", multiple=T)),
              column(6)
              )
        )
      ),
      
      tabItem(
        tabName="about_page",
        h2("About This Dashboard"),
        h5("This dashboard is built to track overall personal finance. May 3, 2023")
      )
    )

      
      
      
    
  )
)

