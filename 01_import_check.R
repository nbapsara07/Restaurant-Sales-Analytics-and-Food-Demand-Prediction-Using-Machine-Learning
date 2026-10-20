# RestaurantIQ - Import and Check Data

install.packages("readxl")  # Run this only once
library(readxl)
file_path <- "C:/Users/Nagaraj/Downloads/RestaurantIQ/data/Restaurant_Sales_Cleaned.xlsx"
# Check available sheets
excel_sheets(file_path)

# Import all three sheets
sales <- read_excel(file_path, sheet = "Sales_Clean")
recipes <- read_excel(file_path, sheet = "Recipe_Clean")
food_mapping <- read_excel(file_path, sheet = "Food_Mapping")

# Check dataset dimensions
dim(sales)
dim(recipes)
dim(food_mapping)

# View column names
names(sales)

# Display first 6 rows
head(sales)

# Check date range
range(sales$Date, na.rm = TRUE)

# Check missing dates
sum(is.na(sales$Date))

# Check number of unique food items
length(unique(sales$`Food Name`))

# Check missing food names and quantities
sum(is.na(sales$`Food Name`))
sum(is.na(sales$Quantity))

# Check quantity summary
summary(sales$Quantity)

# View sample food names
head(unique(sales$`Food Name`), 15)