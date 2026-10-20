
# RestaurantIQ 🍽️
## Restaurant Sales Analytics and Food Demand Prediction Using Machine Learning

RestaurantIQ is a data analytics and machine learning project designed to analyze restaurant sales data, predict food demand, and support better food preparation planning. The project uses historical restaurant sales data to identify demand patterns, compare machine learning models, and help restaurants make data-driven decisions.

## 📌 Project Objectives

- Analyze historical restaurant sales data.
- Identify food demand patterns and trends.
- Train and compare different machine learning models.
- Predict food demand using historical data.
- Recommend food preparation quantities to support restaurant planning.
- Visualize sales analytics and prediction results through an interactive R Shiny dashboard.

## 🛠️ Technologies Used

- **R** – Data analysis and machine learning
- **RStudio** – Development environment
- **Shiny** – Interactive web dashboard
- **shinydashboard** – Dashboard layout and navigation
- **Plotly** – Interactive visualizations
- **DT** – Interactive data tables
- **dplyr** – Data manipulation
- **readr** – Reading and processing CSV files
- **Excel** – Dataset storage and management

## 🤖 Machine Learning Models

Five machine learning approaches are compared in this project:

### 1. Decision Tree
Uses a sequence of decision rules to learn patterns in historical sales data and estimate food demand.

### 2. Random Forest
Combines predictions from multiple decision trees to produce a more stable demand estimate.

### 3. Gradient Boosting
Builds models sequentially, with each new tree attempting to improve on errors made by earlier trees.

### 4. K-Nearest Neighbors (KNN) Regression
Estimates food demand using similar observations from historical data.

### 5. Linear Regression
Models mathematical relationships between input variables and food demand. It also provides a baseline for comparing more complex models.

## 📊 Model Evaluation

The models are evaluated using the following metrics:

- **MAE (Mean Absolute Error):** Measures the average absolute difference between actual and predicted demand. Lower values are better.
- **RMSE (Root Mean Squared Error):** Measures prediction error while penalizing larger errors more heavily. Lower values are better.
- **R² (Coefficient of Determination):** Indicates how much variation in demand is explained by the model. Higher values are generally better.

### Reported Model Results

| Model | MAE | RMSE | R² |
|---|---:|---:|---:|
| Gradient Boosting | 0.706 | 1.472 | 0.260 |
| Linear Regression | 0.709 | 1.493 | 0.239 |
| Random Forest | 0.712 | 1.484 | 0.249 |
| Decision Tree | 0.729 | 1.506 | 0.226 |
| KNN Regression | 0.738 | 1.572 | 0.157 |

Based on these reported results, Gradient Boosting achieved the lowest MAE and RMSE among the five models. However, its R² value indicates that the model still has room for improvement.

## 📈 Dashboard Features

The R Shiny dashboard provides an interactive interface for exploring the project results.

- **Overview:** Displays key project statistics and summary information.
- **Model Performance:** Compares the evaluation metrics of different machine learning models.
- **Predictions:** Displays food demand prediction and validation results.
- **Preparation Planner:** Presents recommended preparation quantities based on estimated demand.
- **Dish Demand Prediction:** Intended to let users select a food item and date to view an estimated demand and preparation quantity, if this feature is enabled in the current version of the application.

The preparation planning logic uses a 15% safety buffer and rounds the recommended quantity up to a whole unit. Actual inventory and remaining stock are not currently accounted for.

## 📂 Project Structure

```text
RestaurantIQ/
├── app.R
├── data/
│   └── Restaurant_Sales_Cleaned.xlsx
├── shared_outputs/
├── 01_import_check.R
├── 02_daily_demand.R
├── 03_eda.R
├── 04_feature_engineering.R
├── 05_model_training.R
├── 06_decision_tree.R
├── 07_random_forest.R
├── 08_gradient_boosting.R
├── 09_svr.R
├── 10_knn_regression.R
├── 12_model_comparison.R
├── 13_prediction_validation.R
├── 14_smart_preparation.R
├── 15_recommendation_summary.R
├── 16_check_project_outputs.R
└── 17_project_report.*
```

*Note: The structure above is representative. Update it to match the files and folders actually committed to this repository. The listed analysis scripts may include additional models beyond the five described in the comparison table.*

## ⚙️ Installation and Setup

### Prerequisites

Install the following software:

- [R](https://cran.r-project.org/)
- [RStudio](https://posit.co/download/rstudio-desktop/)

### Steps to Run the Project

1. Clone or download this repository.
2. Open the project folder in RStudio.
3. Check that the dataset and required output files are present.
4. Install the required R packages by running:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "plotly",
  "DT",
  "dplyr",
  "readr",
  "readxl"
))
```

5. Open `app.R` in RStudio.
6. Click **Run App** to launch the dashboard.

If the application reports that files are missing, check the file paths and confirm that the required CSV outputs and dataset are available in the expected folders.

## 🔬 Methodology

1. Import and inspect the restaurant sales dataset.
2. Clean and prepare the data for analysis.
3. Perform exploratory data analysis to identify demand patterns.
4. Engineer features for machine learning.
5. Train the selected machine learning models.
6. Evaluate and compare model performance using MAE, RMSE, and R².
7. Validate predictions using a chronological train-test split.
8. Use demand estimates to support food preparation planning.
9. Display analytics and results through the R Shiny dashboard.

## 🎯 Expected Benefits

- Better understanding of restaurant sales patterns.
- Data-driven food preparation planning.
- Support for reducing over-preparation and food waste.
- Comparison of machine learning techniques for demand estimation.
- An interactive dashboard for presenting analytics results.

These are intended benefits; actual improvements depend on prediction accuracy and how the recommendations are used in practice.

## ⚠️ Limitations

- Prediction quality depends on the quality and coverage of the historical dataset.
- The reported R² values indicate that the models explain only part of the variation in demand.
- Preparation recommendations use a safety buffer but do not account for current inventory, remaining stock, or actual food waste.
- A date-based estimate from existing validation results should not be treated as a fresh prediction from a trained model unless the application is connected to the saved model and its required feature-generation pipeline.

## 🚀 Future Enhancements

- Integrate saved trained models for genuine predictions on future dates.
- Include holidays, promotions, weather, and special events as additional features.
- Incorporate inventory and remaining-stock information into preparation recommendations.
- Improve prediction accuracy through further feature engineering and model tuning.
- Deploy the Shiny application online for wider access.
- Add more interactive reports and downloadable prediction summaries.

## 👩‍💻 Author

**Project:** RestaurantIQ  
**Title:** Restaurant Sales Analytics and Food Demand Prediction Using Machine Learning

## 📄 License

No license has been specified yet. Add a license file if you intend to define how others may use, modify, and distribute this project.
