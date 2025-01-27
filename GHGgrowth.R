###Evolution of GHG growth in the euro area, European Union (EU27) and worldwide;

library(scales)
library(shiny)
library(patchwork)
library(rsconnect)
library(writexl)

#Loading data

db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

EU<-c("Austria","Belgium","Croatia","Cyprus","Estonia", "Finland","France","Germany","Greence","Ireland","Italy","Latvia","Lithuania",
     "Luxembourg","Malta","Netherlands","Portugal","Slovakia","Slovenia","Spain","EU27", "GLOBAL TOTAL")

EU_string <- paste0("'", paste(EU, collapse = "', '"), "'")

years <- 1970:2023
year_sums <- paste0("SUM(`", years, "`) AS `", years, "`", collapse = ", ")
year_columns <- paste0("`", years, "`", collapse = ", ")

# Build the query dynamically
query <- paste0("
SELECT 
    'EU' AS Country,
    '' AS `EDGAR Country Code`,
    ", year_sums, "
FROM GHG_totals_by_country
WHERE Country IN ('Austria', 'Belgium', 'Croatia', 'Cyprus', 'Estonia', 'Finland', 
                  'France', 'Germany', 'Greece', 'Ireland', 'Italy', 'Latvia', 
                  'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Portugal', 
                  'Slovakia', 'Slovenia', 'Spain', 'Bulgaria', 'Czech Republic', 
                  'Denmark', 'Hungary', 'Poland', 'Romania', 'Sweden')

UNION ALL

SELECT 
    Country,
    `EDGAR Country Code`,
    ", year_columns, "
FROM GHG_totals_by_country
WHERE Country IN ('EU27', 'GLOBAL TOTAL');
")

data <- dbGetQuery(db, query)

cumdata<-data%>%
  mutate("EDGAR Country Code"=NULL)%>%
  pivot_longer(-Country, names_to = "year", values_to = "GHG_emissions")%>%
pivot_wider(names_from = Country,values_from = GHG_emissions)%>%
  rename(Global="GLOBAL TOTAL")%>%
  mutate(year = as.numeric(year))%>%
  mutate(EU=cumsum(EU),EU27=cumsum(EU27),Global=cumsum(Global))%>%
  pivot_longer(-year,names_to = "Region", values_to = "GHG_emissions")

#Separate dfs

ghg <-data%>%
  mutate("EDGAR Country Code"=NULL)%>%
  pivot_longer(-Country, names_to = "year", values_to = "GHG_emissions")%>%
  pivot_wider(names_from = Country,values_from = GHG_emissions)%>%
  rename(Global="GLOBAL TOTAL")%>%
  mutate(year = as.numeric(year))%>%
  pivot_longer(-year, names_to = "Region", values_to = "GHG_emissions")
ghg_cumulative<- cumdata 

##Creating graph

p1 <- ggplot() +
  # Plot Global emissions
  geom_line(data = filter(ghg, Region == "Global"), 
            aes(x = year, y = GHG_emissions, color = Region), 
            size = 1) +
  # Plot EU and EU27 emissions (scaled by 5 for visualization)
  geom_line(data = filter(ghg, Region != "Global"), 
            aes(x = year, y = GHG_emissions * 5, color = Region), 
            size = 1) +
  # Primary y-axis (Global emissions)
  scale_y_continuous(
    name = "Global GHG Emissions",
    labels = label_number(),
    sec.axis = sec_axis(~ . / 5, name = NULL) # Remove secondary y-axis label
  ) +
  labs(
    title = "Yearly GHG Emissions",
    x = "Year",
    color = "Macro Regions"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(hjust = 0.5), 
    axis.text = element_text(size = 8),                   
    axis.title.y = element_text(size = 9),              
    axis.title.y.right = element_blank(),               
    legend.position = "none"                             
  )

# Plot 2: Cumulative GHG Emissions

p2 <- ggplot() +
  # Plot Global emissions
  geom_line(data = filter(ghg_cumulative, Region == "Global"), 
            aes(x = year, y = GHG_emissions, color = Region), 
            size = 1) +
  # Plot EU and EU27 emissions (scaled by 5 for visualization)
  geom_line(data = filter(ghg_cumulative, Region != "Global"), 
            aes(x = year, y = GHG_emissions * 5, color = Region), 
            size = 1) +
  # Primary y-axis (Global emissions)
  scale_y_continuous(
    name = NULL, # Remove primary y-axis label
    labels = label_number(),
    sec.axis = sec_axis(~ . / 5, name = "EU and EU27 GHG Emissions", labels = label_number())
  ) +
  labs(
    title = "Cumulative GHG Emissions",
    x = "Year",
    color = "Macro Regions"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(hjust = 0.5), 
    axis.text = element_text(size = 8),                   
    axis.title.y = element_blank(),                      
    axis.title.y.right = element_text(size = 9),         
    legend.position = "none"                              
  )

# Combine the two plots with patchwork
combined_plot <- p1 + p2 +
  plot_layout(guides = "collect") & 
  theme(
    legend.position = "bottom",                            
    legend.title = element_text(size = 9),                 
    legend.text = element_text(size = 8)                   
  )

# Display the combined plot
plot(combined_plot)




##Shiny App Data Preparation

#Prepare data
ghg_cum<-ghg_cumulative["GHG_emissions"]%>%rename(ghg_cumulative=GHG_emissions)
shinydata<-cbind(ghg,ghg_cum)%>%
rename(ghg_emissions=GHG_emissions,region=Region)

#write_xlsx(shinydata, "shinydata.xlsx")

on.exit(dbDisconnect(db), add = TRUE)





















