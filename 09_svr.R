
library(dplyr)
library(ggplot2)
library(tidyr)
library(e1071)

# 1. Load data
model_data <- read.csv("shared_outputs/Model_Data.csv")
model_data$Date <- as.Date(model_data$Date)
model_data <- na.omit(model_data)

# Features used by the model
features <- c(
  "Day_Of_Week", "Month", "Day_Of_Month",
  "Lag_1", "Lag_7", "Lag_14", "Lag_28",
  "Rolling_Mean_7"
)

# 2. Chronological train-test split
split_date <- sort(unique(model_data$Date))[
  floor(0.8 * length(unique(model_data$Date)))
]

train_data <- model_data %>% filter(Date <= split_date)
test_data <- model_data %>% filter(Date > split_date)

# 3. Scale features using training data only
train_x <- train_data[, features]
test_x <- test_data[, features]

feature_means <- sapply(train_x, mean)
feature_sds <- sapply(train_x, sd)
feature_sds[feature_sds == 0] <- 1

train_x_scaled <- as.data.frame(
  scale(train_x, center = feature_means, scale = feature_sds)
)

test_x_scaled <- as.data.frame(
  scale(test_x, center = feature_means, scale = feature_sds)
)

# 4. Train Support Vector Regression
set.seed(123)

svr_model <- svm(
  x = train_x_scaled,
  y = train_data$Daily_Quantity,
  type = "eps-regression",
  kernel = "radial",
  cost = 10,
  epsilon = 0.1,
  scale = FALSE
)

# 5. Predict
predictions <- predict(svr_model, newdata = test_x_scaled)
predictions <- pmax(0, as.numeric(predictions))

actual <- test_data$Daily_Quantity

# 6. Evaluation metrics
MAE <- mean(abs(actual - predictions))
RMSE <- sqrt(mean((actual - predictions)^2))
R2 <- 1 - sum((actual - predictions)^2) /
  sum((actual - mean(actual))^2)

cat("\nSUPPORT VECTOR REGRESSION RESULTS\n")
cat("--------------------------------\n")
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
  Predicted = predictions
)

results$Error <- results$Actual - results$Predicted

write.csv(
  results,
  "shared_outputs/SVR_Predictions.csv",
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
    title = "SVR: Actual vs Predicted Demand",
    x = "Actual Daily Quantity",
    y = "Predicted Daily Quantity"
  ) +
  theme_minimal()

print(p1)

ggsave(
  "shared_outputs/SVR_Actual_vs_Predicted.png",
  plot = p1, width = 8, height = 5
)

# GRAPH 2: Prediction Error Distribution
p2 <- ggplot(results, aes(x = Error)) +
  geom_histogram(bins = 30, fill = "orange", color = "white") +
  geom_vline(
    xintercept = 0, color = "red", linetype = "dashed"
  ) +
  labs(
    title = "SVR: Prediction Error Distribution",
    x = "Error (Actual - Predicted)",
    y = "Number of Predictions"
  ) +
  theme_minimal()

print(p2)

ggsave(
  "shared_outputs/SVR_Error_Distribution.png",
  plot = p2, width = 8, height = 5
)

# GRAPH 3: Actual vs Predicted for a sample of test rows
set.seed(123)
sample_size <- min(20, nrow(results))
sample_rows <- sample(seq_len(nrow(results)), sample_size)

sample_results <- results[sample_rows, ]
sample_results <- sample_results[
  order(sample_results$Date, sample_results$Food_Name),
]

sample_long <- pivot_longer(
  sample_results,
  cols = c(Actual, Predicted),
  names_to = "Type",
  values_to = "Quantity"
)

p3 <- ggplot(
  sample_long,
  aes(x = Date, y = Quantity, color = Type)
) +
  geom_line(alpha = 0.7) +
  labs(
    title = "SVR: Actual vs Predicted Demand (Sample)",
    x = "Date",
    y = "Daily Quantity",
    color = "Series"
  ) +
  theme_minimal()

print(p3)

ggsave(
  "shared_outputs/SVR_Demand_Comparison.png",
  plot = p3, width = 8, height = 5
)

cat("\nAll 3 graphs and predictions saved successfully!\n")