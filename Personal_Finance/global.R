

pacman::p_load(dplyr, tidyr, shiny, shinydashboard, data.table, DT, shinyWidgets, readr)

shinyapp_path <- '/Users/feliciationardi/Documents/GitHub/shinyapp_scripts/Personal_Finance'
setwd(shinyapp_path)
raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/expenses_data.csv'
spend_raw_data <- read_csv(raw_data_path)


# runApp(shinyapp_path, launch.browser = T)
# runApp()
