install.packages(c("readxl", "dplyr", "ggplot2", "lubridate"))
# ============================================================
# RestaurantIQ: Exploratory Data Analysis (EDA)
# Project: Restaurant Demand Forecasting and Analytics
# ============================================================

# 1. Load required libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(lubridate)

# 2. Import cleaned datasets
file_path <- "C:/Users/Nagaraj/Downloads/RestaurantIQ/data/Restaurant_Sales_Cleaned.xlsx"

sales <- read_excel(file_path, sheet = "Sales_Clean")
food_mapping <- read_excel(file_path, sheet = "Food_Mapping")

daily_demand <- read.csv("shared_outputs/Daily_Demand.csv")
daily_demand$Date <- as.Date(daily_demand$Date)

# Create output folder if it does not exist
dir.create("shared_outputs", showWarnings = FALSE)

# ============================================================
# GRAPH 1: TOP 10 BEST-SELLING FOOD ITEMS
# ============================================================

food_summary <- daily_demand %>%
  group_by(Food_Name) %>%
  summarise(
    Total_Quantity = sum(Daily_Quantity, na.rm = TRUE),
    Average_Daily_Quantity = mean(Daily_Quantity, na.rm = TRUE),
    Days_Sold = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Quantity))

top10 <- head(food_summary, 10)

print(top10)

p1 <- ggplot(
  top10,
  aes(
    x = reorder(Food_Name, Total_Quantity),
    y = Total_Quantity,
    fill = Food_Name
  )
) +
  geom_col(width = 0.75) +
  coord_flip() +
  scale_fill_brewer(palette = "Set3") +
  labs(
    title = "Top 10 Best-Selling Food Items",
    x = "Food Item",
    y = "Total Quantity Sold"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16)
  )

print(p1)

# ============================================================
# GRAPH 2: PIE CHART - TOP 10 FOOD SALES SHARE
# ============================================================

top10_pie <- top10 %>%
  mutate(
    Percentage = Total_Quantity / sum(Total_Quantity) * 100,
    Label = paste0(round(Percentage, 1), "%")
  )

p2 <- ggplot(
  top10_pie,
  aes(x = "", y = Total_Quantity, fill = Food_Name)
) +
  geom_col(color = "white", width = 1) +
  coord_polar(theta = "y") +
  scale_fill_brewer(palette = "Paired") +
  labs(
    title = "Quantity Share of Top 10 Foods",
    fill = "Food Item"
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16)
  )

print(p2)

# ============================================================
# GRAPH 3: MONTHLY DEMAND TREND
# ============================================================

monthly_demand <- daily_demand %>%
  mutate(Month = floor_date(Date, unit = "month")) %>%
  group_by(Month) %>%
  summarise(
    Total_Quantity = sum(Daily_Quantity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Month)

p3 <- ggplot(
  monthly_demand,
  aes(x = Month, y = Total_Quantity)
) +
  geom_line(color = "#0077B6", linewidth = 1.1) +
  geom_point(color = "#F77F00", size = 2) +
  labs(
    title = "Monthly Restaurant Demand Trend",
    x = "Month",
    y = "Total Quantity Sold"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16)
  )

print(p3)

# ============================================================
# GRAPH 4: DISTRIBUTION OF DAILY FOOD-ITEM QUANTITIES
# ============================================================

p4 <- ggplot(
  daily_demand,
  aes(x = Daily_Quantity)
) +
  geom_histogram(
    binwidth = 1,
    fill = "#9B5DE5",
    color = "white"
  ) +
  labs(
    title = "Distribution of Daily Food-Item Quantities",
    x = "Quantity Sold per Food Item per Date",
    y = "Number of Records"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16)
  )

print(p4)

# ============================================================
# GRAPH 5: FOOD CATEGORY-WISE DEMAND
# ============================================================

category_summary <- sales %>%
  filter(!is.na(`Food Category`)) %>%
  group_by(`Food Category`) %>%
  summarise(
    Total_Quantity = sum(Quantity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Quantity))

print(category_summary)

p5 <- ggplot(
  category_summary,
  aes(
    x = reorder(`Food Category`, Total_Quantity),
    y = Total_Quantity,
    fill = `Food Category`
  )
) +
  geom_col(width = 0.75) +
  coord_flip() +
  scale_fill_brewer(palette = "Spectral") +
  labs(
    title = "Demand by Food Category",
    x = "Food Category",
    y = "Total Quantity Sold"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16)
  )

print(p5)

# ============================================================
# GRAPH 6: TOP 10 FOOD ITEMS - AVERAGE DAILY QUANTITY
# ============================================================

p6 <- ggplot(
  top10,
  aes(
    x = reorder(Food_Name, Average_Daily_Quantity),
    y = Average_Daily_Quantity,
    fill = Average_Daily_Quantity
  )
) +
  geom_col(width = 0.75) +
  coord_flip() +
  scale_fill_gradient(
    low = "#90E0EF",
    high = "#7209B7"
  ) +
  labs(
    title = "Average Quantity Sold per Active Day",
    x = "Food Item",
    y = "Average Quantity"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16)
  )

print(p6)

# ============================================================
# ADDITIONAL SUMMARY: DAILY TOTAL DEMAND
# ============================================================

daily_total <- daily_demand %>%
  group_by(Date) %>%
  summarise(
    Total_Quantity = sum(Daily_Quantity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Date)

# ============================================================
# SAVE RESULTS FOR DASHBOARD
# ============================================================

write.csv(
  food_summary,
  "shared_outputs/Food_Summary.csv",
  row.names = FALSE
)

write.csv(
  monthly_demand,
  "shared_outputs/Monthly_Demand.csv",
  row.names = FALSE
)

write.csv(
  category_summary,
  "shared_outputs/Category_Summary.csv",
  row.names = FALSE
)

write.csv(
  daily_total,
  "shared_outputs/Daily_Total_Demand.csv",
  row.names = FALSE
)

cat("\n====================================\n")
cat("RestaurantIQ EDA completed!\n")
cat("Food items analysed:", nrow(food_summary), "\n")
cat("Monthly records:", nrow(monthly_demand), "\n")
cat("Categories analysed:", nrow(category_summary), "\n")
cat("CSV outputs saved in shared_outputs/\n")
cat("====================================\n")