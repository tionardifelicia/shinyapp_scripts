library(shiny)
library(shinydashboard)
library(ggplot2)

# Define UI for the application
ui <- dashboardPage(
  dashboardHeader(title = "Personal Finance Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName="overview_page", icon=icon("display")),
      menuItem("Budget", tabName="budget_page", icon=icon("chart-pie"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "overview_page",
        fluidRow(
          box(
            title = "Chart 1",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotOutput(outputId = "chart1")
          )
        )
      ),
      
      tabItem(
        tabName = "budget_page",
        fluidRow(
          box(
            title = "Chart 2",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            DT::dataTableOutput("budget_table")
          ),
          box(
            title = "Chart 3",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("budget_chart")
          )
        )
      )
    )
  )
)

