

query <- function(api_key, cx, name, mail) {
  
  company <- gsub(".*@|\\..*", "", mail)
  name    <- gsub(" ", "+", name)
  info    <- c()
  
  if (any(grepl(company, c("gmail", "hotmail")))) {
    query_string <- paste("https://www.googleapis.com/customsearch/v1?key=", 
                          api_key, "&cx=", cx, "&q=", "site:linkedin.com+", 
                          name, sep = "")
  } else {
    
    query_string <- paste("https://www.googleapis.com/customsearch/v1?key=", 
                          api_key, "&cx=", cx, "&q=", "site:linkedin.com+", 
                          name, "+", company, sep = "")
    
    if (is.null(content(GET(query_string))$items[[1]]$title)) {
      
      query_string <- paste("https://www.googleapis.com/customsearch/v1?key=", 
                            api_key, "&cx=", cx, "&q=", "site:linkedin.com+", 
                            name, sep = "")
    }
    
  }
  
  if (is.null(content(GET(query_string))$items[[1]]$title)) {
    
    info["title"]     <- "No Result"
    info["workplace"] <- "No Result"
    info["link"]      <- "No Result"
    
  } else {
    result <- content(GET(query_string))$items[[1]]$title
    
    if (grepl("-", result)) {
      info["title"]     <- str_split(result, " - ", simplify = TRUE)[,2]
      info["workplace"] <- str_split(str_split(result, " - ", simplify = TRUE)[,3], 
                                     " | ", simplify = TRUE)[,1]
      info["link"]      <- content(GET(query_string))$items[[1]]$link
      
    } else if (grepl("[\u2013:\u2018]", result)) {
      info["title"]     <- str_split(result, " [\u2013:\u2018] ", simplify = TRUE)[,2]
      info["workplace"] <- str_split(str_split(result, " [\u2013:\u2018] ", simplify = TRUE)[,3], 
                                     " | ", simplify = TRUE)[,1]
      info["link"]      <- content(GET(query_string))$items[[1]]$link
    } else
      info <- "error"
  }
  
  return(info)
  
}