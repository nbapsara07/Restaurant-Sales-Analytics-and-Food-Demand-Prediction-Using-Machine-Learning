# RESTAURANTIQ - SMART FOOD PREPARATION

library(dplyr)

# 1. Load validated predictions
predictions <- read.csv(
  "shared_outputs/GradientBoosting_Validated.csv"
)

predictions$Date <- as.Date(predictions$Date)

# 2. Set preparation rules
safety_buffer <- 0.15  # 15% buffer

# 3. Generate preparation recommendations
recommendations <- predictions %>%
  group_by(Date, Food_Name) %>%
  summarise(
    Predicted_Demand = mean(Predicted_Nonnegative, na.rm = TRUE),
    Actual_Demand = sum(Actual, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Recommended_Preparation = ceiling(
      Predicted_Demand * (1 + safety_buffer)
    ),
    Recommendation = case_when(
      Recommended_Preparation == 0 ~ "No preparation forecast",
      Recommended_Preparation <= 2 ~ "Prepare a small quantity",
      TRUE ~ "Prepare according to forecast"
    )
  )

# 4. Display sample recommendations
print(head(recommendations, 20))

# 5. Save recommendations
write.csv(
  recommendations,
  "shared_outputs/Smart_Preparation_Recommendations.csv",
  row.names = FALSE
)

cat("\nSmart preparation recommendations generated!\n")