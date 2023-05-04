

pacman::p_load(dplyr, tidyr, shiny, shinydashboard, data.table, DT, shinyWidgets, readr, plotly)

shinyapp_path <- '/Users/feliciationardi/Documents/GitHub/shinyapp_scripts/Personal_Finance'
setwd(shinyapp_path)

#### Pull Raw Data ####
base_raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/'
spend_raw_filename <- 'expenses_data.csv'
spend_raw_data <- read_csv(paste0(base_raw_data_path, spend_raw_filename))

budget_raw_filename <- 'budget_data.csv'
budget_raw_data <- read_csv(paste0(base_raw_data_path, budget_raw_filename))



# runApp(shinyapp_path, launch.browser = T)
# runApp()
