####GHGGrowth Shiny App

library(scales)
library(shiny)
library(rsconnect)
library(tidyverse)
library(readxl)


shinydata <- read_excel("/shinydata.xlsx")


ui <- fluidPage(
  titlePanel("GHG Emissions Visualization"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "selected_regions", 
        "Select Regions:", 
        choices = unique(shinydata$region), 
        selected = unique(shinydata$region)
      ),
      radioButtons(
        "time_series_type", 
        "Select Time Series Type:", 
        choices = c("Simple" = "ghg_emissions", "Cumulative" = "ghg_cumulative"), 
        selected = "ghg_emissions"
      )
    ),
    mainPanel(
      plotOutput("ghg_plot")
    )
  )
)

server <- function(input, output) {
  output$ghg_plot <- renderPlot({
    # Filter data based on user selection
    filtered_data <- shinydata %>%
      filter(region %in% input$selected_regions)
    
    # Create plot
    ggplot(filtered_data, aes(x = year, y = !!sym(input$time_series_type), color = region)) +
      geom_line(size = 1) +
      labs(
        title = "GHG Emissions Over Time",
        x = "Year",
        y = ifelse(input$time_series_type == "ghg_emissions", "GHG Emissions", "Cumulative GHG Emissions"),
        color = "Region"
      ) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)


