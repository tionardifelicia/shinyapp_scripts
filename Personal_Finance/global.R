pacman::p_load(dplyr, tidyr, shiny, shinydashboard, data.table, DT, shinyWidgets, readr, plotly, ggplot2, readxl, stringr, crosstalk, lubridate)

shinyapp_path <- '/Users/feliciationardi/Documents/GitHub/shinyapp_scripts/Personal_Finance'
setwd(shinyapp_path)


#### Variables ####
base_date <- as.Date("2023-05-04")
# base_data <- Sys.Date()
current_month <- month(base_date)
current_year <- year(base_date)



#### UI Input Variables ####
input_month_vars <- seq(1,12,by=1)
names(input_month_vars) <- month.abb



#### Pull Raw Data ####
raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/personal_finance_raw_data3.xlsx'
# raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/personal_finance_raw_data_dummies.xlsx'
# raw_data_path <- '/Users/feliciationardi/Documents/productive/raw_data/personal_finance_raw_data.xlsx'


spend_raw_data <- read_excel(raw_data_path, 'expenses_data')
budget_raw_data <- read_excel(raw_data_path, 'budget_data')
networth_raw_data <- read_excel(raw_data_path, 'net_worth_data')
asset_raw_data <- read_excel(raw_data_path, 'assets_data')



#### Clean up Data ####
spend_data <- spend_raw_data %>%
  mutate(year_month=paste0(as.character(year), '_', formatC(month, width=2, flag = "0"))) %>%
  mutate(year_quarter=paste0(as.character(year), '_', as.character((month - 1) %/% 3 + 1)))

networth_data <- networth_raw_data %>%
  mutate(year_month=paste0(as.character(year), '_', formatC(month, width=2, flag = "0"))) %>%
  mutate(year_quarter=paste0(as.character(year), '_', as.character((month - 1) %/% 3 + 1)))



#### Values for Value Boxes ####
# Overview - Variables
ytd_df <- networth_data %>%
  filter(year==year(base_date))

networth_var <- paste("$",
                      formatC(networth_data %>%
                        filter(year==max(year)) %>%
                        filter(month==max(month)) %>%
                        pull(balance),
                      format="f",
                      big.mark=",",
                      digits=0))

ytd_income_var <- paste("$",
                       formatC(ytd_df %>%
                                 pull(income) %>%
                                 sum(),
                               format="f",
                               big.mark=",",
                               digits=0))

ytd_spend_var <- paste("$",
                       formatC(ytd_df %>%
                                 pull(spend) %>%
                                 sum(),
                               format="f",
                               big.mark=",",
                               digits=0))

last_year_var <- paste0(as.character(year(base_date)-1), "_", formatC(month(base_date %m-% months(12)), width=2, flag="0"))
six_months_ago_var <- paste0(as.character(year(base_date)-1), "_", formatC(month(base_date %m-% months(6)), width=2, flag="0"))

# Budget - Variables
budget_var <- sum(budget_raw_data$amount)

# Spend - Variables
mtd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(month==current_month, year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0))

ytd_spend_var <- paste("$",
                       formatC(
                         spend_raw_data %>%
                           filter(year==current_year) %>%
                           pull(amount) %>%
                           sum(),
                         format="f",
                         big.mark=",",
                         digits=0))

mtd_top_spend_var <- spend_raw_data %>%
  filter(month==current_month, year==current_year) %>%
  group_by(category) %>%
  summarize(across(c('amount'), ~sum(.x, na.rm=T))) %>%
  arrange(-amount) %>%
  slice(1) %>%
  pull(category)


# runApp(shinyapp_path, launch.browser = T)
# runApp()
