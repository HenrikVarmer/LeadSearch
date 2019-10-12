


source("./query.R")
lead_search <- function(x, api_key, cx) {
  
  y <- x[,1]
  z <- x[,2]
  
  info <- mapply(query, api_key, cx, y, z)
  
  t <- as.data.frame(info, stringsAsFactors = FALSE)
  
  
  x$tite        <- (t["title", , drop = TRUE])
  x$workplace   <- (t["workplace", , drop = TRUE])
  x$link        <- (t["link", , drop = TRUE])
  
  return(x)
  
}