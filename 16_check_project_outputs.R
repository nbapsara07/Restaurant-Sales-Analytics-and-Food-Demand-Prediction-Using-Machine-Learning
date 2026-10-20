# RESTAURANTIQ - FINAL OUTPUT CHECK

output_folder <- "shared_outputs"

required_files <- c(
  "Model_Comparison.csv",
  "GradientBoosting_Predictions.csv",
  "GradientBoosting_Validated.csv",
  "Smart_Preparation_Recommendations.csv",
  "Food_Preparation_Summary.csv",
  "Comparison_MAE.png",
  "Comparison_RMSE.png",
  "Comparison_R2.png",
  "Validation_Actual_vs_Predicted.png",
  "Validation_Error_Distribution.png",
  "Top_10_Preparation_Recommendations.png"
)

status <- data.frame(
  File = required_files,
  Exists = file.exists(
    file.path(output_folder, required_files)
  )
)

print(status)

cat(
  "\nFiles found:", sum(status$Exists),
  "out of", nrow(status), "\n"
)

missing_files <- status$File[!status$Exists]

if (length(missing_files) > 0) {
  cat("\nMissing files:\n")
  print(missing_files)
} else {
  cat("\nAll required outputs are ready!\n")
}