##GHG Emissions per capita by income group

#Loading data
db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

query <- paste0("
SELECT 
    Country,
    `EDGAR Country Code`,
    ", year_columns, "
FROM GHG_per_capita_by_country;
")

datagdp <- dbGetQuery(db, query)

datainc <- read_excel("IC.xlsx")

datainc <- datainc %>%   filter(if_all(everything(), ~ . != "..")) 
 
#Data manipulation

datainc <- datainc %>%
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "year",
               values_to = "income_group") %>%
  mutate(year = as.numeric(year)) %>% rename(country_code="Country Code")

datagdp <- datagdp %>%
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "year",
               values_to = "ghg_emissions_per_capita") %>%
  mutate(year = as.numeric(year)) %>% rename(country_code="EDGAR Country Code")

#Merge data

merged_data <- datagdp %>%
  inner_join(datainc, by =c("country_code", "Country", "year"))

#Aggregate emíssions

agg_data <- merged_data%>%
  group_by(year, income_group)%>%
  summarise(total_ghg_emissions=sum(ghg_emissions_per_capita, na.rm = TRUE), groups="drop")

#Plot results as stacked area chart

capita <- ggplot(agg_data, aes(x = year, y = total_ghg_emissions, fill = income_group)) +
  geom_area(alpha = 0.8, linewidth = 0.5, color = "white") + 
  scale_fill_brewer(palette = "Set2") + 
  labs(
    title = "Aggregated GHG Emissions per Capita by Income Group (1987-2023)",
    x = "Year",
    y = "Total GHG Emissions Per Capita",
    fill = "Income Group"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),          
    axis.title = element_text(size = 8),            
    legend.title = element_text(size = 8),          
    legend.text = element_text(size = 8)
  )

plot(capita)


on.exit(dbDisconnect(db), add = TRUE)
