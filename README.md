#GHG Emission Analysis 

The goal of this project is to showcase a few global ghg emission trends by means of a combination of SQL and R code, using Shiny applications in RMarkdown for the final exposition. The project answer these three questions through visualizations: 

- Chart 1 – Evolution of GHG growth in the euro area, European Union (EU27) and worldwide;
- Chart 2 – Comparison of countries’ GHG emissions per capita aggregated according to the World Bank income groups;
- Chart 3 – Contribution of individual country and continent GHG emissions to total world GHG emissions. 


##Data

EDGAR_2024_GHG_booklet_2024.xlsx contains the GHG Emission data used in the project. Downloaded from: https://edgar.jrc.ec.europa.eu/report_2024?vis=ghgpop#data_download
Continents.xlsx contains data to categorize countries in continents. 
IncomeClasses.xlsx and IC.xlsx contains time series data for income class categorizations of country, obtained from World Bank database. 

##Scripts

SQL Database: Loading EDGAR report into a SQLite database
GHGgrowth: Data analysis and plot for question 1.
GHGpercapita: Data analysis and plot for question 2.
GHGcontributions: Data analysis and plot for question 3.

##Folders

/AppContributions: Shiny App for question 3. 
/AppGrowth: Shiny App for question 1.

##RMarkdown

GHG-Analysis: Creates pdf file for combining results.



