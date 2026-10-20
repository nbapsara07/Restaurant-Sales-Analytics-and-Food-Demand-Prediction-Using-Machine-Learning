
library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(DT)
library(lubridate)
library(scales)

# RestaurantIQ - Restaurant Operations Analytics Dashboard

# Set project output folder
data_folder <- "shared_outputs"

# Check that the required folder exists
if (!dir.exists(data_folder)) {
  stop("The shared_outputs folder was not found. Please check your project folder.")
}

# Load project results
model_comparison <- read_csv(
  file.path(data_folder, "Model_Comparison.csv"),
  show_col_types = FALSE
)

preparation_data <- read_csv(
  file.path(data_folder, "Smart_Preparation_Recommendations.csv"),
  show_col_types = FALSE
)

validation_data <- read_csv(
  file.path(data_folder, "GradientBoosting_Validated.csv"),
  show_col_types = FALSE
)

# Dashboard user interface
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = "RestaurantIQ",
    titleWidth = 280
  ),
  
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Model Performance", tabName = "models", icon = icon("chart-bar")),
      menuItem("Demand Predictions", tabName = "predictions", icon = icon("chart-line")),
      menuItem("Preparation Planner", tabName = "preparation", icon = icon("utensils")),
      menuItem("Dish Demand Prediction", tabName = "dish_demand", icon = icon("calendar-check"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "overview",
        h2("Restaurant Operations Overview"),
        p("RestaurantIQ uses historical restaurant sales data and machine learning to forecast food demand, evaluate prediction accuracy, and support daily food preparation planning."),
        p("Five machine learning models were evaluated using a chronological train-test split. Gradient Boosting achieved the lowest Mean Absolute Error (MAE) among the models tested."),
        
        
        fluidRow(
          valueBoxOutput("total_foods", width = 3),
          valueBoxOutput("total_predictions", width = 3),
          valueBoxOutput("best_model", width = 3),
          valueBoxOutput("best_mae", width = 3)
        ),
        
p("Model comparison: lower MAE and RMSE indicate smaller prediction errors. Higher R² indicates that a model explains more variation in demand. Gradient Boosting performed best overall among the five models evaluated."),

        fluidRow(
          box(
            title = "Model Accuracy (MAE)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("overview_plot", height = "350px")
          ),
          box(
            title = "Prediction Error (RMSE)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("rmse_plot", height = "350px")
          )
        ),
        
        fluidRow(
          box(
            title = "Model Fit (R²)",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("r2_plot", height = "350px")
          )
        )
      ),
      
      tabItem(
        tabName = "models",
        h2("Machine Learning Model Performance"),
        fluidRow(
          valueBoxOutput("model_winner", width = 12)
        ),
        p("Five machine learning models were evaluated on a chronological test set. Gradient Boosting achieved the lowest MAE (0.706) and RMSE (1.472), with an R² of 0.260. These results indicate that it performed best overall among the tested models, although its ability to explain demand variation remains limited."),
        
        fluidRow(
          box(
            title = "Model Metrics Comparison",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("model_table")
          )
        )
      ),
      
      tabItem(
        tabName = "predictions",
        h2("Demand Predictions"),
        
        p("Compare actual sales with Gradient Boosting demand forecasts over the selected date range. Use the food and date filters to investigate prediction errors and identify where forecasts may differ from actual demand."),
        
        fluidRow(
          valueBoxOutput("prediction_mae", width = 4),
          valueBoxOutput("prediction_rmse", width = 4),
          valueBoxOutput("prediction_r2", width = 4)
        ),
        
        p("Interpretation: Lower MAE and RMSE indicate smaller forecast errors. R² measures how much variation in actual demand is explained by the predictions; a negative R² means the model performs worse than predicting the average actual demand for the selected data."),
        
        fluidRow(
          box(
            title = "Filter Predictions",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            selectInput(
              "food_filter",
              "Select Food Item",
              choices = c("All Foods", sort(unique(validation_data$Food_Name)))
            ),
            
            dateRangeInput(
              "date_filter",
              "Select Date Range",
              start = min(as.Date(validation_data$Date), na.rm = TRUE),
              end = max(as.Date(validation_data$Date), na.rm = TRUE),
              min = min(as.Date(validation_data$Date), na.rm = TRUE),
              max = max(as.Date(validation_data$Date), na.rm = TRUE)
            )
            
          )
        ),
        
        box(
          title = "Actual vs Predicted Demand",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          tags$p(
            textOutput("prediction_chart_summary"),
            style = "font-size: 14px; color: #555; margin-bottom: 10px;"
          ),
          plotlyOutput("demand_plot", height = "400px")
        ),
        
        box(
          title = "Prediction Details",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          DTOutput("filtered_prediction_table")
        ),
        
        box(
          title = "Prediction Data",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          DTOutput("prediction_table")
        )
      ),
      
      tabItem(
        
        tabName = "preparation",
        h2("Smart Food Preparation Planner"),
        
        p(
          "Preparation recommendations use forecast demand plus a 15% safety buffer, rounded up to whole units. They are preliminary estimates and do not account for current inventory, waste, or remaining stock."
        ),
        
        
p("Use the filters to review preparation recommendations for a selected food item and date range. Total recommended quantities represent preliminary preparation estimates, not confirmed inventory requirements."),

        
        fluidRow(
          valueBoxOutput("total_food_items", width = 4),
          valueBoxOutput("total_recommended_quantity", width = 4),
          valueBoxOutput("forecast_recommendations", width = 4)
        ),
        
        
        fluidRow(
          box(
            title = "Filter Recommendations",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            selectInput(
              "prep_food_filter",
              "Select Food Item",
              choices = c(
                "All Foods",
                sort(unique(preparation_data$Food_Name))
              )
            ),
            dateRangeInput(
              "prep_date_filter",
              "Select Date Range",
              start = min(as.Date(preparation_data$Date), na.rm = TRUE),
              end = max(as.Date(preparation_data$Date), na.rm = TRUE),
              min = min(as.Date(preparation_data$Date), na.rm = TRUE),
              max = max(as.Date(preparation_data$Date), na.rm = TRUE)
            )
          )
        ),
        box(
          title = "Daily Recommended Preparation Trend",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          plotlyOutput("preparation_trend_plot", height = "400px")
        ),
        box(
          title = "Preparation Recommendations",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          DTOutput("preparation_table"),
          downloadButton("download_preparation", "Download Preparation Plan")
        )
      ),
      tabItem(
        tabName = "dish_demand",
        h2("Dish Demand Prediction"),
        p("Select a dish and date to estimate demand."),
        
        fluidRow(
          box(
            title = "Prediction Inputs",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            
            selectInput(
              "dish_name",
              "Select Dish",
              choices = sort(unique(validation_data$Food_Name))
            ),
            
            dateInput(
              "demand_date",
              "Select Date",
              value = Sys.Date() + 1,
              min = Sys.Date()
            ),
            
            actionButton(
              "predict_demand",
              "Predict Demand",
              icon = icon("calculator"),
              class = "btn-primary"
            )
          ),
          
          box(
            title = "Demand Estimate",
            status = "success",
            solidHeader = TRUE,
            width = 8,
            
            h3("Predicted Portions"),
            textOutput("predicted_portions"),
            
            h3("Suggested Preparation (+15% buffer)"),
            textOutput("suggested_portions")
          )
        )
      )
    )
  )
)

# Dashboard server logic
server <- function(input, output, session) {
  demand_estimate <- eventReactive(input$predict_demand, {
    req(input$dish_name, input$demand_date)
    
    dish_data <- validation_data %>%
      filter(
        Food_Name == input$dish_name,
        !is.na(Predicted),
        is.finite(Predicted)
      )
    
    req(nrow(dish_data) > 0)
    
    selected_date <- as.Date(input$demand_date)
    selected_weekday <- weekdays(selected_date)
    
    dish_data$Date <- as.Date(dish_data$Date)
    
    matching_days <- dish_data %>%
      filter(weekdays(Date) == selected_weekday)
    
    if (nrow(matching_days) > 0) {
      raw_prediction <- mean(matching_days$Predicted, na.rm = TRUE)
    } else {
      raw_prediction <- mean(dish_data$Predicted, na.rm = TRUE)
    }
    
    predicted <- ceiling(max(0, raw_prediction))
    suggested <- ceiling(predicted * 1.15)
    
    list(
      predicted = predicted,
      suggested = suggested
    )
  })
  
  output$predicted_portions <- renderText({
    result <- demand_estimate()
    paste(result$predicted, "portions")
  })
  
  output$suggested_portions <- renderText({
    result <- demand_estimate()
    paste(result$suggested, "portions")
  })
  output$total_foods <- renderValueBox({
    valueBox(
      value = dplyr::n_distinct(preparation_data$Food_Name),
      subtitle = "Total Food Items",
      icon = icon("utensils"),
      color = "blue"
    )
  })
  
  output$total_predictions <- renderValueBox({
    valueBox(
      value = nrow(validation_data),
      subtitle = "Validated Predictions",
      icon = icon("chart-line"),
      color = "green"
    )
  })
  
  output$best_model <- renderValueBox({
    best_row <- model_comparison[which.min(model_comparison$MAE), ]
    
    valueBox(
      value = as.character(best_row$Model),
      subtitle = "Best Model by MAE",
      icon = icon("trophy"),
      color = "purple"
    )
  })
  
  output$best_mae <- renderValueBox({
    best_row <- model_comparison[which.min(model_comparison$MAE), ]
    
    valueBox(
      value = round(best_row$MAE, 3),
      subtitle = "Lowest MAE",
      icon = icon("bullseye"),
      color = "purple"
    )
  })
  
  output$overview_plot <- renderPlotly({
    
    plot_ly(
      data = model_comparison,
      x = ~reorder(Model, -MAE),
      y = ~MAE,
      type = "bar",
      text = ~sprintf("%.3f", MAE),
      textposition = "outside",
      marker = list(
        color = "#2878B5",
        line = list(color = "#1B527A", width = 1)
      ),
      hovertemplate = paste(
        "<b>%{x}</b>",
        "<br>Mean Absolute Error: %{y:.3f}",
        "<extra></extra>"
      )
    ) %>%
      layout(
        title = list(
          text = "Model Accuracy Comparison",
          x = 0.05
        ),
        xaxis = list(
          title = "Machine Learning Model",
          tickangle = -20
        ),
        yaxis = list(
          title = "Mean Absolute Error (MAE)",
          rangemode = "tozero"
        ),
        margin = list(b = 110, t = 70),
        showlegend = FALSE
      ) %>%
      config(
        displayModeBar = TRUE,
        displaylogo = FALSE
      )
  })
  output$rmse_plot <- renderPlotly({
    
    plot_ly(
      data = model_comparison,
      x = ~reorder(Model, -RMSE),
      y = ~RMSE,
      type = "bar",
      text = ~sprintf("%.3f", RMSE),
      textposition = "outside",
      marker = list(
        color = "#16A085",
        line = list(color = "#117A65", width = 1)
      ),
      hovertemplate = paste(
        "<b>%{x}</b>",
        "<br>Root Mean Squared Error: %{y:.3f}",
        "<extra></extra>"
      )
    ) %>%
      layout(
        title = list(
          text = "Model RMSE Comparison",
          x = 0.05
        ),
        xaxis = list(
          title = "Machine Learning Model",
          tickangle = -20
        ),
        yaxis = list(
          title = "Root Mean Squared Error (RMSE)",
          rangemode = "tozero"
        ),
        margin = list(b = 110, t = 70),
        showlegend = FALSE
      ) %>%
      config(
        displayModeBar = TRUE,
        displaylogo = FALSE
      )
  })
  output$r2_plot <- renderPlotly({
    
    plot_ly(
      data = model_comparison,
      x = ~reorder(Model, -R2),
      y = ~R2,
      type = "bar",
      text = ~sprintf("%.3f", R2),
      textposition = "outside",
      marker = list(
        color = "#8E44AD",
        line = list(color = "#633974", width = 1)
      ),
      hovertemplate = paste(
        "<b>%{x}</b>",
        "<br>R²: %{y:.3f}",
        "<extra></extra>"
      )
    ) %>%
      layout(
        title = list(
          text = "Model R² Comparison",
          x = 0.05
        ),
        xaxis = list(
          title = "Machine Learning Model",
          tickangle = -20
        ),
        yaxis = list(
          title = "R² Score",
          rangemode = "tozero"
        ),
        margin = list(b = 110, t = 70),
        showlegend = FALSE
      ) %>%
      config(
        displayModeBar = TRUE,
        displaylogo = FALSE
      )
  })
  # Filter predictions by selected food item
  
  filtered_predictions <- reactive({
    data <- validation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= input$date_filter[1],
        Date <= input$date_filter[2]
      )
    
    if (input$food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$food_filter)
    }
    
    data
  })
  
  
  # Interactive actual vs predicted demand chart
  
  output$prediction_chart_summary <- renderText({
    data <- filtered_predictions()
    
    if (nrow(data) == 0) {
      return("No prediction records match the selected filters.")
    }
    
    paste0(
      "Showing ", format(nrow(data), big.mark = ","),
      " prediction records from ",
      format(min(as.Date(data$Date)), "%d %b %Y"),
      " to ",
      format(max(as.Date(data$Date)), "%d %b %Y"),
      "."
    )
  })
  
  output$demand_plot <- renderPlotly({
    plot_data <- filtered_predictions() %>%
      mutate(Date = as.Date(Date)) %>%
      arrange(Date)
    
    if (nrow(plot_data) == 0) {
      return(
        plotly_empty() %>%
          layout(title = "No prediction data for this selection")
      )
    }
    
    plot_data <- plot_data %>%
      mutate(
        Actual = round(Actual, 2),
        Predicted = round(Predicted, 2)
      )
    
    plot_ly(data = plot_data, x = ~Date) %>%
      add_lines(
        y = ~Actual,
        name = "Actual Demand",
        line = list(color = "#2878B5", width = 2),
        hovertemplate = paste(
          "Date: %{x|%Y-%m-%d}",
          "<br>Actual Demand: %{y:.2f}",
          "<extra></extra>"
        )
      ) %>%
      add_lines(
        y = ~Predicted,
        name = "Predicted Demand",
        line = list(color = "#E67E22", width = 2),
        hovertemplate = paste(
          "Date: %{x|%Y-%m-%d}",
          "<br>Predicted Demand: %{y:.2f}",
          "<extra></extra>"
        )
      ) %>%
      layout(
        title = "Actual vs Predicted Demand",
        xaxis = list(title = "Date"),
        yaxis = list(title = "Demand", rangemode = "tozero"),
        legend = list(orientation = "h", x = 0.2, y = -0.2),
        hovermode = "x unified"
      )
  })
  
  
  
  output$filtered_prediction_table <- renderDT({
    filtered_predictions() %>%
      mutate(Date = as.Date(Date)) %>%
      select(Date, Food_Name, Actual, Predicted, Error, Absolute_Error) %>%
      datatable(
        options = list(
          pageLength = 10,
          scrollX = TRUE
        ),
        filter = "top",
        rownames = FALSE
      ) %>%
      formatDate(
        columns = "Date",
        method = "toLocaleDateString"
      ) %>%
      formatRound(
        columns = c("Actual", "Predicted", "Error", "Absolute_Error"),
        digits = 2
      )
  })
  
  
  output$model_winner <- renderValueBox({
    best_row <- model_comparison[
      which.min(model_comparison$MAE),
    ]
    
    valueBox(
      value = as.character(best_row$Model),
      subtitle = paste(
        "Best Model | MAE:",
        round(best_row$MAE, 3),
        "| RMSE:",
        round(best_row$RMSE, 3),
        "| R²:",
        round(best_row$R2, 3)
      ),
      icon = icon("trophy"),
      color = "green"
    )
  })
  
  
  output$model_table <- renderDT({
    
    best_model_name <- model_comparison$Model[
      which.min(model_comparison$MAE)
    ]
    ranked_models <- model_comparison %>%
      arrange(MAE) %>%
      mutate(Rank = row_number()) %>%
      select(Rank, everything())
    datatable(
      ranked_models %>%
        mutate(
          MAE = round(MAE, 3),
          RMSE = round(RMSE, 3),
          R2 = round(R2, 3)
        ),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      rownames = FALSE
    ) %>%
      formatStyle(
        "Model",
        target = "row",
        backgroundColor = styleEqual(
          best_model_name,
          "#D4EDDA"
        ),
        fontWeight = styleEqual(
          best_model_name,
          "bold"
        )
      )
  })
  
  
  output$prediction_mae <- renderValueBox({
    data <- filtered_predictions()
    
    mae_value <- if (nrow(data) > 0) {
      mean(data$Absolute_Error, na.rm = TRUE)
    } else {
      NA_real_
    }
    
    valueBox(
      value = if (is.finite(mae_value)) round(mae_value, 3) else "N/A",
      subtitle = "Mean Absolute Error (MAE)",
      icon = icon("bullseye"),
      color = "blue"
    )
  })
  
  
  
  output$prediction_rmse <- renderValueBox({
    data <- filtered_predictions()
    
    rmse_value <- if (nrow(data) > 0) {
      sqrt(mean(data$Error^2, na.rm = TRUE))
    } else {
      NA_real_
    }
    
    valueBox(
      value = if (is.finite(rmse_value)) round(rmse_value, 3) else "N/A",
      subtitle = "Root Mean Squared Error (RMSE)",
      icon = icon("chart-line"),
      color = "green"
    )
  })
  
  
  
  output$prediction_r2 <- renderValueBox({
    data <- filtered_predictions()
    
    r2_value <- if (nrow(data) > 1) {
      actual_mean <- mean(data$Actual, na.rm = TRUE)
      
      ss_total <- sum(
        (data$Actual - actual_mean)^2,
        na.rm = TRUE
      )
      
      ss_residual <- sum(
        (data$Actual - data$Predicted)^2,
        na.rm = TRUE
      )
      
      if (ss_total > 0) {
        1 - ss_residual / ss_total
      } else {
        NA_real_
      }
    } else {
      NA_real_
    }
    
    valueBox(
      value = if (is.finite(r2_value)) round(r2_value, 3) else "N/A",
      subtitle = "Filtered R² Score",
      icon = icon("chart-bar"),
      color = "purple"
    )
  })
  
  
  
  
  
  output$prediction_table <- renderDT({
    validation_data %>%
      mutate(Date = as.Date(Date)) %>%
      datatable(
        options = list(
          pageLength = 10,
          scrollX = TRUE
        ),
        filter = "top",
        rownames = FALSE
      ) %>%
      formatDate(
        columns = "Date",
        method = "toLocaleDateString"
      ) %>%
      formatRound(
        columns = c(
          "Actual",
          "Predicted",
          "Error",
          "Absolute_Error",
          "Predicted_Nonnegative"
        ),
        digits = 2
      )
  })
  
  
  output$total_food_items <- renderValueBox({
    data <- preparation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= as.Date(input$prep_date_filter[1]),
        Date <= as.Date(input$prep_date_filter[2])
      )
    
    if (input$prep_food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$prep_food_filter)
    }
    
    valueBox(
      value = dplyr::n_distinct(data$Food_Name),
      subtitle = "Total Food Items",
      icon = icon("cutlery"),
      color = "blue"
    )
  })
  
  output$total_recommended_quantity <- renderValueBox({
    data <- preparation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= as.Date(input$prep_date_filter[1]),
        Date <= as.Date(input$prep_date_filter[2])
      )
    
    if (input$prep_food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$prep_food_filter)
    }
    
    valueBox(
      value = format(
        sum(data$Recommended_Preparation, na.rm = TRUE),
        big.mark = ","
      ),
      subtitle = "Total Recommended Quantity",
      icon = icon("calculator"),
      color = "green"
    )
  })
  
  output$forecast_recommendations <- renderValueBox({
    data <- preparation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= as.Date(input$prep_date_filter[1]),
        Date <= as.Date(input$prep_date_filter[2])
      )
    
    if (input$prep_food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$prep_food_filter)
    }
    
    forecast_count <- sum(
      data$Recommendation == "Prepare according to forecast",
      na.rm = TRUE
    )
    
    valueBox(
      value = forecast_count,
      subtitle = "Forecast-Based Recommendations",
      icon = icon("chart-line"),
      color = "purple"
    )
  })
  
  output$preparation_trend_plot <- renderPlotly({
    data <- preparation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= as.Date(input$prep_date_filter[1]),
        Date <= as.Date(input$prep_date_filter[2])
      )
    
    if (input$prep_food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$prep_food_filter)
    }
    
    if (nrow(data) == 0) {
      return(
        plotly_empty() %>%
          layout(
            title = "No preparation data for this selection",
            xaxis = list(title = "Date"),
            yaxis = list(title = "Recommended Preparation Quantity")
          )
      )
    }
    
    daily_data <- data %>%
      group_by(Date) %>%
      summarise(
        Recommended_Quantity = sum(
          Recommended_Preparation,
          na.rm = TRUE
        ),
        .groups = "drop"
      ) %>%
      arrange(Date)
    
    plot_ly(
      data = daily_data,
      x = ~Date,
      y = ~Recommended_Quantity,
      type = "scatter",
      mode = "lines",
      line = list(color = "#2878B5", width = 2),
      hovertemplate = paste(
        "Date: %{x|%d %b %Y}",
        "<br>Recommended Quantity: %{y:.0f}",
        "<extra></extra>"
      )
    ) %>%
      layout(
        title = "Daily Recommended Preparation",
        xaxis = list(title = "Date"),
        yaxis = list(
          title = "Recommended Preparation Quantity",
          rangemode = "tozero"
        ),
        hovermode = "x unified",
        margin = list(b = 60, l = 70)
      )
  })
  
  
  output$preparation_table <- renderDT({
    data <- preparation_data %>%
      mutate(Date = as.Date(Date)) %>%
      filter(
        Date >= as.Date(input$prep_date_filter[1]),
        Date <= as.Date(input$prep_date_filter[2])
      )
    
    if (input$prep_food_filter != "All Foods") {
      data <- data %>%
        filter(Food_Name == input$prep_food_filter)
    }
    
    datatable(
      data,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        order = list(list(0, "asc"))
      ),
      filter = "top",
      rownames = FALSE
    ) %>%
      formatDate(
        columns = "Date",
        method = "toLocaleDateString"
      ) %>%
      formatRound(
        columns = c(
          "Predicted_Demand",
          "Actual_Demand",
          "Recommended_Preparation"
        ),
        digits = 0
      ) %>%
      formatStyle(
        "Recommended_Preparation",
        backgroundColor = "#D9EAF7",
        fontWeight = "bold"
      ) %>%
      formatStyle(
        "Recommendation",
        backgroundColor = styleEqual(
          c(
            "Prepare according to forecast",
            "Prepare a small quantity"
          ),
          c("#D4EDDA", "#FFF3CD")
        ),
        fontWeight = "bold"
      )
  })
  
  
  output$download_preparation <- downloadHandler(
    filename = function() {
      paste0("RestaurantIQ_Preparation_Plan_", Sys.Date(), ".csv")
    },
    
    content = function(file) {
      data <- preparation_data %>%
        mutate(Date = as.Date(Date)) %>%
        filter(
          Date >= as.Date(input$prep_date_filter[1]),
          Date <= as.Date(input$prep_date_filter[2])
        )
      
      if (input$prep_food_filter != "All Foods") {
        data <- data %>%
          filter(Food_Name == input$prep_food_filter)
      }
      
      readr::write_csv(data, file)
    }
  )
  
  
  
}
# Launch the dashboard
shinyApp(ui = ui, server = server)
