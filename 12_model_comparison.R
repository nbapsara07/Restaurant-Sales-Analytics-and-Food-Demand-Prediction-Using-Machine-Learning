# RESTAURANTIQ - MODEL COMPARISON

library(ggplot2)
library(dplyr)

# 1. Set output folder
output_folder <- "shared_outputs"

# 2. List the five models and their prediction files
files <- c(
  "Linear Regression" = "Linear_Predictions.csv",
  "Decision Tree" = "DecisionTree_Predictions.csv",
  "Random Forest" = "RandomForest_Predictions.csv",
  "Gradient Boosting" = "GradientBoosting_Predictions.csv",
  "KNN Regression" = "KNN_Predictions.csv"
)

# 3. Calculate evaluation metrics
comparison <- data.frame()

for (model_name in names(files)) {
  
  file_path <- file.path(output_folder, files[model_name])
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    next
  }
  
  predictions <- read.csv(file_path)
  
  if (!all(c("Actual", "Predicted") %in% names(predictions))) {
    warning(paste("Actual or Predicted column missing:", file_path))
    next
  }
  
  predictions <- predictions %>%
    filter(is.finite(Actual), is.finite(Predicted))
  
  actual <- predictions$Actual
  predicted <- predictions$Predicted
  
  mae <- mean(abs(actual - predicted))
  rmse <- sqrt(mean((actual - predicted)^2))
  
  r_squared <- if (length(actual) > 1 &&
                   sum((actual - mean(actual))^2) > 0) {
    1 - sum((actual - predicted)^2) /
      sum((actual - mean(actual))^2)
  } else {
    NA_real_
  }
  
  comparison <- rbind(
    comparison,
    data.frame(
      Model = model_name,
      MAE = mae,
      RMSE = rmse,
      R2 = r_squared
    )
  )
}

# 4. Display results
print(comparison)

# 5. Save comparison table
write.csv(
  comparison,
  file.path(output_folder, "Model_Comparison.csv"),
  row.names = FALSE
)

# 6. Graph 1: MAE comparison
p1 <- ggplot(comparison,
             aes(x = reorder(Model, MAE), y = MAE)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Model Comparison - MAE",
    x = "Model",
    y = "Mean Absolute Error"
  ) +
  theme_minimal()

ggsave(file.path(output_folder, "Comparison_MAE.png"),
       p1, width = 8, height = 5)

# 7. Graph 2: RMSE comparison
p2 <- ggplot(comparison,
             aes(x = reorder(Model, RMSE), y = RMSE)) +
  geom_col(fill = "darkorange") +
  coord_flip() +
  labs(
    title = "Model Comparison - RMSE",
    x = "Model",
    y = "Root Mean Squared Error"
  ) +
  theme_minimal()

ggsave(file.path(output_folder, "Comparison_RMSE.png"),
       p2, width = 8, height = 5)

# 8. Graph 3: R-squared comparison
p3 <- ggplot(comparison,
             aes(x = reorder(Model, R2), y = R2)) +
  geom_col(fill = "seagreen") +
  coord_flip() +
  labs(
    title = "Model Comparison - R-squared",
    x = "Model",
    y = "R-squared"
  ) +
  theme_minimal()

ggsave(file.path(output_folder, "Comparison_R2.png"),
       p3, width = 8, height = 5)

cat("Model comparison completed!\n")