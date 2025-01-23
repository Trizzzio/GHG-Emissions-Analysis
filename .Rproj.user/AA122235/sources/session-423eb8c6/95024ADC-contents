##Loading Data and creating SQL database

library(tidyverse)
library(readxl)
library(DBI)
library(RSQLite)

file <- "EDGAR_2024_GHG_booklet_2024.xlsx"

#SQL connection

db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

sheet_names <- excel_sheets(file)
sheet_names <- sheet_names[-(1:2)]

##Loop through sheets and add them to sql database

for (sheet in sheet_names){
  
  data <- read_excel(file, sheet=sheet)
  
  dbWriteTable(db, name = sheet, value =data, row.names = FALSE, overwrite=TRUE)
  
}   

dbListTables(db)

on.exit(dbDisconnect(db), add = TRUE)