

library(stringr)
library(httr)
library(dplyr)
library(stringi)
source("./R/g_query.R")
source("./R/b_query.R")
source("./R/lead_search.R")


# read in local content + API keys
leads     <- read.csv("leads.csv", sep = ";", stringsAsFactors = FALSE)
conf      <- read.csv("api_key.csv", sep = ";", stringsAsFactors = FALSE)[1,]
g_api_key <- conf$api_key
b_api_key <- conf$b_api_key
g_cx      <- conf$cx
b_cx      <- conf$b_cx

x <- leads[1:100,]

#lead_search(x, engine = "google", g_api_key, g_cx)

started <- Sys.time()
g <- lead_search(leads, engine = "bing", b_api_key, b_cx)
ended <- Sys.time()
ended - started
head(g)




write.csv(g, file = "test.csv", row.names =FALSE, sep = ";")
