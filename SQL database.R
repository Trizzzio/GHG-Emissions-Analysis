##Loading Data and creating SQL database

library(tidyverse)
library(readxl)
library(DBI)
library(RSQLite)


##GHG data

file1 <- "EDGAR_2024_GHG_booklet_2024.xlsx"

#SQL connection

db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

sheet_names <- excel_sheets(file1)
sheet_names <- sheet_names[-(1:2)]

##Loop through sheets and add them to sql database

for (sheet in sheet_names){
  
  data <- read_excel(file, sheet=sheet)
  
  dbWriteTable(db, name = sheet, value =data, row.names = FALSE, overwrite=TRUE)
  
}   


##Income Group data


file2 <- "IncomeClasses.xlsx"

#SQL connection

db<- dbConnect(SQLite(), dbname="ghg_emissions.sqlite")

sheet_names <- excel_sheets(file2)
sheet_names <- sheet_names[-(1:2)]

for (sheet in sheet_names){
  
  data <- read_excel(file2, sheet=sheet)
  
  dbWriteTable(db, name = sheet, value =data, row.names = FALSE, overwrite=TRUE)
  
}   


dbListTables(db)

on.exit(dbDisconnect(db), add = TRUE)