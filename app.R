### GLOBAL

library(shiny)
library(tidyverse)


superstore <- readxl::read_xls("./sample_-_superstore.xls") %>% 
  suppressWarnings()


min_date <- min(superstore$`Order Date`) %>% 
  as.Date()

max_date <- max(superstore$`Order Date`) %>% 
  as.Date()


all_years_profit_sum <- superstore %>%
  filter(`Order Date` < ymd("2017-06-01")) %>%
  group_by(year = year(`Order Date`), Category) %>%
  summarise(sum_profit = sum(Profit)/1000, .groups = 'drop')

profit_2017 <- all_years_profit_sum %>%
  filter(year==2017) %>%
  pull()

profit_mean_and_median <- superstore %>%
  filter(`Order Date` < ymd("2017-06-01")) %>%
  group_by(Category) %>%
  summarise(mean_profit = mean(Profit),
            median_profit = median(Profit), .groups = 'drop')



####

ui <- fluidPage(
  
  h5(""),
  
  sidebarLayout(
    
    sidebarPanel(
      
      sliderInput("date.range",
                  "Date Range (slider):",
                  min = min_date,
                  max = max_date,
                  value = c(min_date, max_date)),
      
      dateRangeInput("date.calendar",
                     "Date Range (calendar):",
                     start = min_date,
                     end = max_date,
                     min = min_date,
                     max = max_date,
                     separator = "to",
                     format = "dd-mm-yyyy"),
      
      radioButtons(inputId = "forecast_type",
                   label = "Type of the forecast",
                   choices = list("Mean" = "mean_profit", 
                                  "Median" = "median_profit"),
                   selected = "mean_profit"),
      
      numericInput(inputId = "generosity",
                   label = "Generosity of the forecast (in %)",
                   min = 0,
                   max = 100,
                   value = 50),
      
      actionButton(inputId = "reset",
                   label = "Reset"),
      
      
      width = 3
    ),
    
    mainPanel(

      fluidRow(
        column(width = 6, plotOutput("bar1"), height = "300px"),
        column(width = 6, plotOutput("bar2"), height = "300px")
      ),

      fluidRow(
        column(width = 3, plotOutput("stackbar1"), height = "300px"),
        column(width = 3, plotOutput("stackbar2"), height = "300px"),
        column(width = 6, plotOutput("predbar"), height = "300px")
      )

    )
  )
  
)


server <- function(input, output, session) {

  superstore_by_cat <- reactive({
    superstore %>% 
      filter((input$date.range[1] < `Order Date`) & (input$date.range[2] > `Order Date`)) %>% 
      group_by(Category) %>% 
      summarise(Quantity = mean(Quantity),
                Profit = mean(Profit))
  })
  
  quantity_by_cat <- reactive({
    superstore_by_cat() %>% 
      arrange(Quantity) %>% 
      mutate(Category = factor(Category, levels = Category))
  })
  
  profit_by_cat <- reactive({
    superstore_by_cat() %>% 
      arrange(Profit) %>% 
      mutate(Category = factor(Category, levels = Category))
  })
  
  
  # obserwator zmieniający wartość z kalendarzyka na sliderze
  observeEvent(input$date.calendar, {
    
    updateSliderInput(session,
                      "date.range",
                      value = input$date.calendar) 
  })
  
  # obserwator zmieniający wartość ze slidera na kalendarzyku
  observeEvent(input$date.range, {
    
    updateDateRangeInput(session,
                         "date.calendar", 
                         start = input$date.range[1], 
                         end = input$date.range[2]) 
  })
  
  # obserwator do guzika reset
  observeEvent(input$reset, {
    updateSliderInput(inputId = "date.range", value = c(min_date, max_date))
    updateDateRangeInput(inputId = "date.calendar", start = min_date, end = max_date)
    updateRadioButtons(inputId = "forecast_type", selected = "mean_profit")
    updateNumericInput(inputId = "generosity", value = 50) 
  })
  
  # Bar chart 1
  output$bar1 <- renderPlot({
    
    ggplot(quantity_by_cat(), aes(x = Category, y = Quantity, fill = Category)) + 
      geom_col(width = 0.3) + 
      labs(title = "Average quantity by categories", 
           x= "Category", y="Quanity") +
      geom_text(aes(label = str_glue("{round(Quantity,2)}")), color = "white", size = 5, position = position_stack(vjust = 0.5)) +
      theme(legend.position = "none",
            panel.background = element_blank(), 
            panel.grid = element_line(color="gray90"), 
            panel.grid.major.x = element_blank(),
            plot.title = element_text(hjust = 0.5))
    
  })
  
  # Bar chart 2
  output$bar2 <- renderPlot({
    
    ggplot(profit_by_cat(), aes(x = Category, y = Profit, fill = Category)) + 
      geom_col() + 
      labs(title = "Average profit by categories", 
           x= "Category", y="Profit [k$]") +
      geom_text(aes(label = str_glue("{round(Profit,2)}")), color = "white", size = 5, position = position_stack(vjust = 0.5)) +
      theme(legend.position = "none",
            panel.background = element_blank(), 
            panel.grid = element_line(color="gray90"), 
            panel.grid.major.x = element_blank(),
            plot.title = element_text(hjust = 0.5))
    
  })
  
  # Stacked bar chart 1
  output$stackbar1 <- renderPlot({
    
    ggplot(quantity_by_cat(), aes(x = 1, y = Quantity, fill = Category)) +
      geom_bar(stat = "identity", position = "stack", width = 0.1) +
      labs(title = "Average quantity by categories", x = "Category", y = "Quantity") +
      geom_text(aes(label = str_glue("{Category}: {round(Quantity,2)}")), color = "gray100", alpha=0.5, size = 8, position = position_stack(vjust = 0.5)) +
      theme(panel.background = element_blank(),
            panel.grid=element_blank(),
            panel.grid.major.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.text.x=element_blank(),
            legend.position="none",
            plot.title = element_text(hjust = 0.5))
    
  })
  
  # Stacked bar chart 2
  output$stackbar2 <- renderPlot({
    
    ggplot(profit_by_cat(), aes(x = 1, y = Profit, fill = Category)) +
      geom_bar(stat = "identity", position = "stack", width = 0.1) +
      labs(title = "Average profit by categories", x = "Category", y = "Profit") +
      geom_text(aes(label = str_glue("{Category}: {round(Profit,2)}")), color = "gray100", alpha=0.5, size = 5, position = position_stack(vjust = 0.5)) +
      theme(panel.background = element_blank(),
            panel.grid=element_blank(),
            panel.grid.major.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.text.x=element_blank(),
            legend.position="none",
            plot.title = element_text(hjust = 0.5))
    
  })
  
  
  profit_forecast <- reactive({
    
    all_years_profit_sum %>%
      mutate(is_real = 1) %>%
      rbind(tibble(year = c(2017,2017,2017),
                   Category = profit_mean_and_median$Category,
                   sum_profit = profit_2017 + (input$generosity/100) * 6*profit_mean_and_median[[input$forecast_type]]/12,
                   is_real = c(0.4,0.4,0.4)))
    
  })
  
  # Prediction bar chart
  output$predbar <- renderPlot({

    ggplot(profit_forecast(), aes(Category, sum_profit, fill = Category, alpha = is_real)) +
      geom_bar(position = "dodge", stat = "identity", show.legend = FALSE) +
      scale_alpha_identity() +
      labs(title = "Profit over the years by category (with forecast in 2017)",
           x = "Category",
           y = "Profit [k$]") +
      facet_wrap(~year, nrow = 4) +
      coord_flip() +
      theme(panel.background = element_blank(),
            panel.grid.major.x = element_line(color="gray90"),
            plot.title = element_text(hjust = 0.5))

  })
  
}



shinyApp(ui = ui, server = server)
