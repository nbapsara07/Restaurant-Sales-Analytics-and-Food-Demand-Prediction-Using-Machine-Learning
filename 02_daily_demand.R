# RestaurantIQ - Daily Demand Aggregation

library(readxl)
library(dplyr)
library(lubridate)

# Import cleaned sales data
file_path <- "data/Restaurant_Sales_Cleaned.xlsx"
sales <- read_excel(file_path, sheet = "Sales_Clean")

# Prepare date and food columns
sales <- sales %>%
  mutate(
    Date = as.Date(Date),
    Food_Name = trimws(`Food Name`),
    Quantity = as.numeric(Quantity)
  )

# Aggregate quantities by date and food item
daily_demand <- sales %>%
  group_by(Date, Food_Name) %>%
  summarise(
    Daily_Quantity = sum(Quantity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Food_Name, Date)

# Check results
head(daily_demand)
dim(daily_demand)
length(unique(daily_demand$Food_Name))

# Save output for modelling and dashboard
dir.create("shared_outputs", showWarnings = FALSE)

write.csv(
  daily_demand,
  "shared_outputs/Daily_Demand.csv",
  row.names = FALSE
)