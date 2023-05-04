

pacman::p_load(dplyr, tidyr, shiny, shinydashboard, data.table, DT, shinyWidgets, readr, plotly)

shinyapp_path <- '/Users/feliciationardi/Documents/GitHub/shinyapp_scripts/Personal_Finance'
setwd(shinyapp_path)


#### Variables ####
base_date <- as.Date("2023-05-04")
current_month <- month(base_date)
current_year <- year(base_date)




#### Pull Raw Data ####
base_raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/'
spend_raw_filename <- 'expenses_data.csv'
spend_raw_data <- read_csv(paste0(base_raw_data_path, spend_raw_filename))

budget_raw_filename <- 'budget_data.csv'
budget_raw_data <- read_csv(paste0(base_raw_data_path, budget_raw_filename))



#### Values for Spend Value Boxes ####
mtd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(month==current_month, year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0
                       )
)

ytd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0
                       )
)

mtd_top_spend_var <- spend_raw_data %>%
  filter(month==current_month, year==current_year) %>%
  group_by(category) %>%
  summarize(across(c('amount'), ~sum(.x, na.rm=T))) %>%
  arrange(-amount) %>%
  slice(1) %>%
  pull(category)



# runApp(shinyapp_path, launch.browser = T)
# runApp()
