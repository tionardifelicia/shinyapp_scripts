options(spinner.type = 4) # spinner type

ui <- dashboardPage(
  
  dashboardHeader(title = 'Personal Finance Dashboard'),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem('Overview', tabName='overview_page', icon=icon('chart-pie')),
      menuItem('About', tabName='about_page', icon=icon('circle-info'))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview_page",
              h2("Welcome to My Dashboard"),
              p("This is the home page.")
      ),
      tabItem(tabName = "about_page",
              h2("About This Dashboard"),
              br(),
              br(),
              p("This dashboard was created using Shiny and Shinydashboard on May 3, 2023."),
              p("The purpose of this dashboard is to track personal finance.")
      )
    )
  )
  
  
)