
library(dplyr)
library(caret)

# Load feature-engineered data
model_data <- read.csv("shared_outputs/Model_Data.csv")
model_data$Date <- as.Date(model_data$Date)

# Remove rows with missing feature values
model_data <- na.omit(model_data)

# Split chronologically: first 80% for training, last 20% for testing
split_date <- sort(unique(model_data$Date))[
  floor(0.8 * length(unique(model_data$Date)))
]

train_data <- model_data %>%
  filter(Date <= split_date)

test_data <- model_data %>%
  filter(Date > split_date)

# Train Linear Regression
linear_model <- lm(
  Daily_Quantity ~ Day_Of_Week + Month + Day_Of_Month +
    Lag_1 + Lag_7 + Lag_14 + Lag_28 + Rolling_Mean_7,
  data = train_data
)

# Predict test demand
predictions <- predict(linear_model, newdata = test_data)

# Demand cannot be negative
predictions <- pmax(0, predictions)

# Evaluate model
actual <- test_data$Daily_Quantity

MAE <- mean(abs(actual - predictions))
RMSE <- sqrt(mean((actual - predictions)^2))

R2 <- 1 - sum((actual - predictions)^2) /
  sum((actual - mean(actual))^2)

cat("Linear Regression Results\n")
cat("Split date:", as.character(split_date), "\n")
cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows:", nrow(test_data), "\n")
cat("MAE:", round(MAE, 3), "\n")
cat("RMSE:", round(RMSE, 3), "\n")
cat("R-squared:", round(R2, 3), "\n")




# Prepare results for visualization
results <- data.frame(
  Actual = actual,
  Predicted = predictions
)

# Graph 1: Actual vs Predicted Demand
library(ggplot2)

p1 <- ggplot(results, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.25, color = "steelblue") +
  geom_abline(intercept = 0, slope = 1,
              color = "red", linetype = "dashed") +
  labs(
    title = "Linear Regression: Actual vs Predicted Demand",
    x = "Actual Daily Quantity",
    y = "Predicted Daily Quantity"
  ) +
  theme_minimal()

print(p1)

# Graph 2: Model Performance Metrics
metrics <- data.frame(
  Metric = c("MAE", "RMSE", "R-squared"),
  Value = c(MAE, RMSE, R2)
)

p2 <- ggplot(metrics, aes(x = Metric, y = Value, fill = Metric)) +
  geom_col() +
  labs(
    title = "Linear Regression Performance Metrics",
    x = "Evaluation Metric",
    y = "Value"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p2)

# Graph 3: Actual vs Predicted Demand for First 100 Test Rows
sample_results <- results[1:min(100, nrow(results)), ]
sample_results$Observation <- seq_len(nrow(sample_results))

sample_long <- tidyr::pivot_longer(
  sample_results,
  cols = c(Actual, Predicted),
  names_to = "Type",
  values_to = "Quantity"
)

p3 <- ggplot(
  sample_long,
  aes(x = Observation, y = Quantity, color = Type)
) +
  geom_line() +
  labs(
    title = "Actual vs Predicted Demand (First 100 Test Rows)",
    x = "Test Observation",
    y = "Daily Quantity",
    color = "Series"
  ) +
  theme_minimal()

print(p3)

# Save graph images for the report
ggsave("shared_outputs/Linear_Actual_vs_Predicted.png",
       p1, width = 8, height = 5)

ggsave("shared_outputs/Linear_Performance_Metrics.png",
       p2, width = 8, height = 5)

ggsave("shared_outputs/Linear_Demand_Comparison.png",
       p3, width = 8, height = 5)

linear_predictions <- data.frame(
  Date = test_data$Date,
  Food_Name = test_data$Food_Name,
  Actual = test_data$Daily_Quantity,
  Predicted = as.numeric(predictions)
)

write.csv(
  linear_predictions,
  "shared_outputs/Linear_Predictions.csv",
  row.names = FALSE
)