
library(dplyr)
library(ggplot2)
library(tidyr)
library(rpart)

# Load data
model_data <- read.csv("shared_outputs/Model_Data.csv")
model_data$Date <- as.Date(model_data$Date)
model_data <- na.omit(model_data)

# Chronological train/test split
split_date <- sort(unique(model_data$Date))[
  floor(0.8 * length(unique(model_data$Date)))
]

train_data <- model_data %>% filter(Date <= split_date)
test_data  <- model_data %>% filter(Date > split_date)

# Train Decision Tree Regression
tree_model <- rpart(
  Daily_Quantity ~ Day_Of_Week + Month + Day_Of_Month +
    Lag_1 + Lag_7 + Lag_14 + Lag_28 + Rolling_Mean_7,
  data = train_data,
  method = "anova"
)

# Predict
predictions <- predict(tree_model, newdata = test_data)
predictions <- pmax(0, predictions)

actual <- test_data$Daily_Quantity

# Evaluation metrics
MAE <- mean(abs(actual - predictions))
RMSE <- sqrt(mean((actual - predictions)^2))
R2 <- 1 - sum((actual - predictions)^2) /
  sum((actual - mean(actual))^2)

cat("Decision Tree Results\n")
cat("Split date:", as.character(split_date), "\n")
cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows:", nrow(test_data), "\n")
cat("MAE:", round(MAE, 3), "\n")
cat("RMSE:", round(RMSE, 3), "\n")
cat("R-squared:", round(R2, 3), "\n")

# Prepare results
results <- data.frame(Actual = actual, Predicted = predictions)

# Graph 1: Actual vs Predicted
p1 <- ggplot(results, aes(Actual, Predicted)) +
  geom_point(alpha = 0.25, color = "steelblue") +
  geom_abline(intercept = 0, slope = 1,
              color = "red", linetype = "dashed") +
  labs(title = "Decision Tree: Actual vs Predicted Demand",
       x = "Actual Daily Quantity",
       y = "Predicted Daily Quantity") +
  theme_minimal()

print(p1)

# Graph 2: Performance metrics
metrics <- data.frame(
  Metric = c("MAE", "RMSE", "R-squared"),
  Value = c(MAE, RMSE, R2)
)

p2 <- ggplot(metrics, aes(Metric, Value, fill = Metric)) +
  geom_col() +
  labs(title = "Decision Tree Performance Metrics",
       x = "Metric", y = "Value") +
  theme_minimal() +
  theme(legend.position = "none")

print(p2)

# Graph 3: Actual vs Predicted for first 100 test rows
sample_results <- results[1:min(100, nrow(results)), ]
sample_results$Observation <- seq_len(nrow(sample_results))

sample_long <- pivot_longer(
  sample_results,
  cols = c(Actual, Predicted),
  names_to = "Type",
  values_to = "Quantity"
)

p3 <- ggplot(sample_long,
             aes(Observation, Quantity, color = Type)) +
  geom_line() +
  labs(title = "Decision Tree: Actual vs Predicted (First 100 Rows)",
       x = "Test Observation", y = "Daily Quantity",
       color = "Series") +
  theme_minimal()

print(p3)

# Save graphs
ggsave("shared_outputs/DecisionTree_Actual_vs_Predicted.png",
       p1, width = 8, height = 5)
ggsave("shared_outputs/DecisionTree_Performance_Metrics.png",
       p2, width = 8, height = 5)
ggsave("shared_outputs/DecisionTree_Demand_Comparison.png",
       p3, width = 8, height = 5)

# Save predictions
write.csv(
  data.frame(
    Date = test_data$Date,
    Food_Name = test_data$Food_Name,
    Actual = actual,
    Predicted = predictions
  ),
  "shared_outputs/DecisionTree_Predictions.csv",
  row.names = FALSE
)

cat("Decision Tree graphs and predictions saved!\n")





# Graph 2: Prediction Error Distribution
results$Error <- results$Actual - results$Predicted

p2 <- ggplot(results, aes(x = Error)) +
  geom_histogram(bins = 30, fill = "orange", color = "white") +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Decision Tree: Prediction Error Distribution",
    x = "Prediction Error (Actual - Predicted)",
    y = "Frequency"
  ) +
  theme_minimal()

print(p2)

ggsave("shared_outputs/DecisionTree_Error_Distribution.png",
       p2, width = 8, height = 5)

# Graph 3: Feature Importance
importance <- data.frame(
  Feature = names(tree_model$variable.importance),
  Importance = as.numeric(tree_model$variable.importance)
)

p3 <- ggplot(
  importance,
  aes(x = reorder(Feature, Importance), y = Importance)
) +
  geom_col(fill = "seagreen") +
  coord_flip() +
  labs(
    title = "Decision Tree: Feature Importance",
    x = "Feature",
    y = "Importance"
  ) +
  theme_minimal()

print(p3)

ggsave("shared_outputs/DecisionTree_Feature_Importance.png",
       p3, width = 8, height = 5)