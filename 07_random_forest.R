
library(dplyr)
library(ggplot2)
library(tidyr)
library(randomForest)

# 1. Load data
model_data <- read.csv("shared_outputs/Model_Data.csv")
model_data$Date <- as.Date(model_data$Date)

model_data <- na.omit(model_data)

# Create output folder if needed
if (!dir.exists("shared_outputs")) {
  dir.create("shared_outputs")
}

# 2. Chronological train-test split
split_date <- sort(unique(model_data$Date))[
  floor(0.8 * length(unique(model_data$Date)))
]

train_data <- model_data %>% filter(Date <= split_date)
test_data  <- model_data %>% filter(Date > split_date)

# 3. Train Random Forest Regression
set.seed(123)

rf_model <- randomForest(
  Daily_Quantity ~ Day_Of_Week + Month + Day_Of_Month +
    Lag_1 + Lag_7 + Lag_14 + Lag_28 + Rolling_Mean_7,
  data = train_data,
  ntree = 100,
  importance = TRUE
)

# 4. Predict demand
predictions <- predict(rf_model, newdata = test_data)
predictions <- pmax(0, predictions)

actual <- test_data$Daily_Quantity

# 5. Evaluate model
MAE <- mean(abs(actual - predictions))
RMSE <- sqrt(mean((actual - predictions)^2))
R2 <- 1 - sum((actual - predictions)^2) /
  sum((actual - mean(actual))^2)

cat("\nRANDOM FOREST RESULTS\n")
cat("---------------------\n")
cat("Split date:", as.character(split_date), "\n")
cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows:", nrow(test_data), "\n")
cat("MAE:", round(MAE, 3), "\n")
cat("RMSE:", round(RMSE, 3), "\n")
cat("R-squared:", round(R2, 3), "\n")

# Save predictions
results <- data.frame(
  Date = test_data$Date,
  Food_Name = test_data$Food_Name,
  Actual = actual,
  Predicted = as.numeric(predictions)
)

results$Error <- results$Actual - results$Predicted

write.csv(
  results,
  "shared_outputs/RandomForest_Predictions.csv",
  row.names = FALSE
)

# GRAPH 1: Actual vs Predicted Demand
p1 <- ggplot(results, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.25, color = "steelblue") +
  geom_abline(
    intercept = 0, slope = 1,
    color = "red", linetype = "dashed"
  ) +
  labs(
    title = "Random Forest: Actual vs Predicted Demand",
    x = "Actual Daily Quantity",
    y = "Predicted Daily Quantity"
  ) +
  theme_minimal()

print(p1)

ggsave(
  "shared_outputs/RandomForest_Actual_vs_Predicted.png",
  plot = p1, width = 8, height = 5
)

# GRAPH 2: Prediction Error Distribution
p2 <- ggplot(results, aes(x = Error)) +
  geom_histogram(
    bins = 30, fill = "orange", color = "white"
  ) +
  geom_vline(
    xintercept = 0, color = "red", linetype = "dashed"
  ) +
  labs(
    title = "Random Forest: Prediction Error Distribution",
    x = "Error (Actual - Predicted)",
    y = "Number of Predictions"
  ) +
  theme_minimal()

print(p2)

ggsave(
  "shared_outputs/RandomForest_Error_Distribution.png",
  plot = p2, width = 8, height = 5
)

# GRAPH 3: Feature Importance
importance_values <- randomForest::importance(rf_model)

importance <- data.frame(
  Feature = rownames(importance_values),
  Importance = as.numeric(importance_values[, "%IncMSE"])
)

importance <- importance[is.finite(importance$Importance), ]

p3 <- ggplot(
  importance,
  aes(x = reorder(Feature, Importance), y = Importance)
) +
  geom_col(fill = "seagreen") +
  coord_flip() +
  labs(
    title = "Random Forest: Feature Importance",
    x = "Feature",
    y = "Importance (%IncMSE)"
  ) +
  theme_minimal()

print(p3)

ggsave(
  "shared_outputs/RandomForest_Feature_Importance.png",
  plot = p3, width = 8, height = 5
)

cat("\nAll 3 graphs and predictions saved successfully!\n")