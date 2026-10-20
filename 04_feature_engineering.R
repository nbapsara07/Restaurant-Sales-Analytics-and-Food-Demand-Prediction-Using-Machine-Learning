
library(dplyr)
library(lubridate)
library(tidyr)

# Load daily demand
daily_demand <- read.csv("shared_outputs/Daily_Demand.csv")
daily_demand$Date <- as.Date(daily_demand$Date)

# Create a complete calendar for every food item
all_dates <- seq(
  min(daily_demand$Date),
  max(daily_demand$Date),
  by = "day"
)

all_foods <- unique(daily_demand$Food_Name)

model_data <- expand_grid(
  Date = all_dates,
  Food_Name = all_foods
) %>%
  left_join(daily_demand, by = c("Date", "Food_Name")) %>%
  mutate(Daily_Quantity = replace_na(Daily_Quantity, 0L)) %>%
  arrange(Food_Name, Date) %>%
  group_by(Food_Name) %>%
  mutate(
    Day_Of_Week = wday(Date, week_start = 1),
    Month = month(Date),
    Day_Of_Month = day(Date),
    Lag_1 = lag(Daily_Quantity, 1),
    Lag_7 = lag(Daily_Quantity, 7),
    Lag_14 = lag(Daily_Quantity, 14),
    Lag_28 = lag(Daily_Quantity, 28),
    Rolling_Mean_7 = (
      lag(Daily_Quantity, 1) +
        lag(Daily_Quantity, 2) +
        lag(Daily_Quantity, 3) +
        lag(Daily_Quantity, 4) +
        lag(Daily_Quantity, 5) +
        lag(Daily_Quantity, 6) +
        lag(Daily_Quantity, 7)
    ) / 7
  ) %>%
  ungroup() %>%
  filter(!is.na(Lag_28), !is.na(Rolling_Mean_7))

# Save model-ready data
write.csv(
  model_data,
  "shared_outputs/Model_Data.csv",
  row.names = FALSE
)

cat("Feature engineering completed!\n")
cat("Rows:", nrow(model_data), "\n")
cat("Food items:", length(unique(model_data$Food_Name)), "\n")
cat("Columns:", ncol(model_data), "\n")

head(model_data)




nrow(model_data)
length(unique(model_data$Food_Name))
sum(is.na(model_data$Daily_Quantity))
