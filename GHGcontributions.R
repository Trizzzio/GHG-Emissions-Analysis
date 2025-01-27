##Contribution of inidividual and continent GHG emissions to total world GHG emissions. 
library(treemapify)
library(shiny)
library(readxl)

#Loading data

db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

query <- paste0("
SELECT 
    Country,
    `EDGAR Country Code`,
    ", year_columns, "
FROM GHG_totals_by_country;
")

dataghg <- dbGetQuery(db, query) %>% rename(country_code="EDGAR Country Code")

datacont <- read_excel("Continents.xlsx")

#merge data

merged_data <- dataghg %>%
  inner_join(datacont, by="country_code")%>%slice(1:(n() - 2))%>%rename(country="Country.x")%>%mutate(Country.y=NULL)

##Plotting contributions
#Plotting continent contributions as stacked area chart


contaggdata<-merged_data%>%
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "year", values_to = "ghg_emissions")%>%
  group_by(year, Continent)%>%
  summarise(continent_emissions=sum(ghg_emissions, na.rm=TRUE))%>%
  mutate(year = as.numeric(year))

ggplot(contaggdata, aes(x = year, y = continent_emissions, fill = Continent)) +
  geom_area(alpha = 0.8, linewidth = 0.5, color = "white") +  # Add stacked area with borders
  scale_fill_brewer(palette = "Set2") +  # Use a color palette for clarity
  labs(
    title = "Aggregated GHG Emissions per Continent",
    x = "Year",
    y = "Total GHG Emissions",
    fill = "Continents"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text( hjust = 0.5),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8)
  )

#Plotting country contributions as Treemap

treemap<-merged_data%>%
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "year", values_to = "ghg_emissions")%>%
  group_by(Continent, country) %>%
  summarize(total_emissions = sum(ghg_emissions, na.rm = TRUE), .groups = "drop")

# Plot the treemap
tree<-ggplot(treemap, aes(area = total_emissions, fill = Continent, label = country, subgroup = Continent)) +
  geom_treemap() +
  geom_treemap_text(colour = "white", place = "centre", reflow = TRUE) +
  geom_treemap_subgroup_border(colour = "black") +
  labs(
    title = "GHG Emissions Contribution by Country and Continent",
    fill = "Continent"
  ) +
  theme_minimal()

plot(tree)

#Treemap Shiny app for time-series

Shinytreemapp<-merged_data%>%
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "year", values_to = "ghg_emissions")%>%
  group_by(Continent, country,year) %>%
  summarize(total_emissions = sum(ghg_emissions, na.rm = TRUE), .groups = "drop")%>%
  mutate(year = as.numeric(year))

#write_xlsx(Shinytreemapp, "Shinytreemapp.xlsx")




on.exit(dbDisconnect(db), add = TRUE)
