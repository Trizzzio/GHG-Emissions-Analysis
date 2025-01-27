####Contribution Shiny App

library(scales)
library(shiny)
library(rsconnect)
library(tidyverse)
library(readxl)
library(treemapify)
library(here)

Shinytreemapp <- read_excel("Shinytreemapp.xlsx")


ui <- fluidPage(
  titlePanel("GHG Emissions Contribution by Country and Continent"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "year",
        label = "Select Year:",
        min = min(Shinytreemapp$year),
        max = max(Shinytreemapp$year),
        value = min(Shinytreemapp$year),
        step = 1,
        sep = ""
      )
    ),
    
    mainPanel(
      plotOutput("treemap", height = "600px")
    )
  )
)

server <- function(input, output) {
  # Filter data based on the selected year
  filtered_data <- reactive({
    Shinytreemapp %>% filter(year == input$year)
  })
  
  # Render the treemap
  output$treemap <- renderPlot({
    req(filtered_data())  # Ensure data exists
    
    ggplot(filtered_data(), aes(
      area = total_emissions,
      fill = Continent,
      label = country,
      subgroup = Continent
    )) +
      geom_treemap() +
      geom_treemap_text(colour = "white", place = "centre", reflow = TRUE) +
      geom_treemap_subgroup_border(colour = "black") +
      labs(
        title = paste("GHG Emissions Contribution in", input$year),
        fill = "Continent"
      ) +
      theme_minimal()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)