

library(stringr)
library(httr)
library(dplyr)
source("./query.R")
source("./lead_search.R")

# read in local content + API keys
leads   <- read.csv("leads.csv", sep = ";", stringsAsFactors = FALSE)
conf    <- read.csv("api_key.csv", sep = ";", stringsAsFactors = FALSE)[1,]
api_key <- conf$api_key
cx      <- conf$cx



lead_search(leads, api_key, cx)


query(api_key, cx, name, mail)

