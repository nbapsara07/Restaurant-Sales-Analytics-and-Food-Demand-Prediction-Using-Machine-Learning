# RESTAURANTIQ - PREDICTION VALIDATION

library(dplyr)
library(ggplot2)

# 1. Load Gradient Boosting predictions
predictions <- read.csv(
  "shared_outputs/GradientBoosting_Predictions.csv"
)

# 2. Check the data
cat("Total predictions:", nrow(predictions), "\n")
cat("Missing actual values:", sum(is.na(predictions$Actual)), "\n")
cat("Missing predicted values:", sum(is.na(predictions$Predicted)), "\n")

# 3. Calculate prediction errors
predictions <- predictions %>%
  mutate(
    Error = Actual - Predicted,
    Absolute_Error = abs(Error),
    Predicted_Nonnegative = pmax(Predicted, 0)
  )

# 4. Display summary
cat("\nACTUAL DEMAND SUMMARY\n")
print(summary(predictions$Actual))

cat("\nPREDICTED DEMAND SUMMARY\n")
print(summary(predictions$Predicted))

cat("\nERROR SUMMARY\n")
print(summary(predictions$Error))

# 5. Count negative predictions
cat(
  "\nNegative predictions:",
  sum(predictions$Predicted < 0, na.rm = TRUE),
  "\n"
)

# 6. Save validation results
write.csv(
  predictions,
  "shared_outputs/GradientBoosting_Validated.csv",
  row.names = FALSE
)

# 7. Graph: Actual versus predicted demand
p1 <- ggplot(predictions, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.25) +
  geom_abline(
    intercept = 0, slope = 1,
    color = "red", linetype = "dashed"
  ) +
  labs(
    title = "Gradient Boosting: Actual vs Predicted Demand",
    x = "Actual Quantity Sold",
    y = "Predicted Quantity"
  ) +
  theme_minimal()

ggsave(
  "shared_outputs/Validation_Actual_vs_Predicted.png",
  p1, width = 8, height = 5
)

# 8. Graph: Prediction error distribution
p2 <- ggplot(predictions, aes(x = Error)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Prediction Error Distribution",
    x = "Actual - Predicted",
    y = "Number of Predictions"
  ) +
  theme_minimal()

ggsave(
  "shared_outputs/Validation_Error_Distribution.png",
  p2, width = 8, height = 5
)

cat("\nPrediction validation completed!\n")