


lead_search <- function(x, engine = "google", api_key, cx) {

  if(engine == "bing") {

    y <- x[,1]
    z <- x[,2]

    info <- mapply(b_query, api_key, cx, y, z)

    t <- as.data.frame(info, stringsAsFactors = FALSE)


    x$title       <- (t["title", ,     drop = TRUE])
    x$workplace   <- (t["workplace", , drop = TRUE])
    x$link        <- (t["link", ,      drop = TRUE])

  } else if(engine == "google") {

    y <- x[,1]
    z <- x[,2]

    info <- mapply(g_query, api_key, cx, y, z)

    t <- as.data.frame(info, stringsAsFactors = FALSE)


    x$title       <- (t["title", ,     drop = TRUE])
    x$workplace   <- (t["workplace", , drop = TRUE])
    x$link        <- (t["link", ,      drop = TRUE])


  }

  return(x)

}


