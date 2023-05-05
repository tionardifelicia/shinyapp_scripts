pacman::p_load(dplyr, tidyr, shiny, shinydashboard, data.table, DT, shinyWidgets, readr, plotly, ggplot2, readxl)

shinyapp_path <- '/Users/feliciationardi/Documents/GitHub/shinyapp_scripts/Personal_Finance'
setwd(shinyapp_path)


#### Variables ####
base_date <- as.Date("2023-05-04")
# base_data <- Sys.Date()
current_month <- month(base_date)
current_year <- year(base_date)



#### Pull Raw Data ####
raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/personal_finance_raw_data_dummies.xlsx'
# base_raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/personal_finance_raw_data.xlsx'
spend_raw_filename <- 'expenses_data.csv'
spend_raw_data <- read_excel(raw_data_path, 'expenses_data')
budget_raw_data <- read_excel(raw_data_path, 'budget_data')
networth_data <- read_excel(raw_data_path, 'net_worth_data')



#### Values for Spend Value Boxes ####
budget_var <- sum(budget_raw_data$amount)

mtd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(month==current_month, year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0)
)

ytd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0)
)

mtd_top_spend_var <- spend_raw_data %>%
  filter(month==current_month, year==current_year) %>%
  group_by(category) %>%
  summarize(across(c('amount'), ~sum(.x, na.rm=T))) %>%
  arrange(-amount) %>%
  slice(1) %>%
  pull(category)



#### Clean up Data ####
spend_data <- spend_raw_data %>%
  mutate(year_month=paste0(as.character(year), '_', formatC(month, width=2, flag = "0"))) %>%
  mutate(year_quarter=paste0(as.character(year), '_', as.character((month - 1) %/% 3 + 1)))

head(spend_data)



#### Input Variables ####
input_month_vars <- seq(1,12,by=1)
names(input_month_vars) <- month.abb

input_month_vars


# runApp(shinyapp_path, launch.browser = T)
# runApp()
