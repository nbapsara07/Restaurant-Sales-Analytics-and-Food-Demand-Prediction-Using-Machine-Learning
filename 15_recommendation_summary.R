# RESTAURANTIQ - RECOMMENDATION SUMMARY

library(dplyr)
library(ggplot2)

# Load recommendations
recommendations <- read.csv(
  "shared_outputs/Smart_Preparation_Recommendations.csv"
)

# Summarise across the prediction period
food_summary <- recommendations %>%
  group_by(Food_Name) %>%
  summarise(
    Average_Predicted_Demand = round(mean(Predicted_Demand), 2),
    Total_Actual_Demand = sum(Actual_Demand),
    Average_Recommended_Preparation =
      round(mean(Recommended_Preparation), 2),
    Total_Recommended_Preparation =
      sum(Recommended_Preparation),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Recommended_Preparation))

# Save summary
write.csv(
  food_summary,
  "shared_outputs/Food_Preparation_Summary.csv",
  row.names = FALSE
)

# Graph: Top 10 foods by recommended preparation
top_foods <- head(food_summary, 10)

p <- ggplot(
  top_foods,
  aes(
    x = reorder(Food_Name, Total_Recommended_Preparation),
    y = Total_Recommended_Preparation
  )
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Foods by Recommended Preparation",
    x = "Food Item",
    y = "Total Recommended Units"
  ) +
  theme_minimal()

ggsave(
  "shared_outputs/Top_10_Preparation_Recommendations.png",
  p,
  width = 9,
  height = 6
)

print(head(food_summary, 10))

cat("\nRecommendation summary completed!\n")