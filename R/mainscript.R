library(quantmod)
library(DBI)
library(dplyr)
library(tidyverse)
library(RSQLite)

######################################################################################
# create database or connect to one
#my_db <- src_sqlite("portal-database-output.sqlite", create = TRUE)
my_db <- DBI::dbConnect(RSQLite::SQLite(), "portal-database-output.sqlite")

######################################################################################
# specify currencies and variables to fetch

currency<-c("AUDUSD","EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY")
#####################################################################################
source("collector script.R")
