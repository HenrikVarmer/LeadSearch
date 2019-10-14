

b_query <- function(b_api_key, b_cx, name, mail) {

  company <- gsub(".*@|\\..*", "", mail)
  name    <- URLencode(stri_enc_toutf8(name))
  info    <- c()

  if (any(grepl(company, c("gmail", "hotmail", "")))) {
    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%20",
                          name, "&customconfig=", b_cx, "&mkt=da-DK", sep = "")
  } else {

    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%20",
                          name, "%20", company, "&customconfig=", b_cx, "&mkt=da-DK", sep = "")

    if (is.null(content(httr::GET(url = query_string,
                                  add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$name)) {

    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%20",
                            name, "&customconfig=", b_cx, "&mkt=da-DK", sep = "")
    }

  }

  if (is.null(content(httr::GET(url = query_string,
                                add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$name)) {

    info["title"]     <- "No Result"
    info["workplace"] <- "No Result"
    info["link"]      <- "No Result"

  } else {
    result <- content(httr::GET(url = query_string,
                                add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$name

    if (grepl("-", result)) {
      info["title"]     <- str_split(result, " - ", simplify = TRUE)[,2]
      info["workplace"] <- str_split(str_split(result, " - ", simplify = TRUE)[,3],
                                     " | ", simplify = TRUE)[,1]
      info["link"]      <- content(httr::GET(url = query_string,
                                             add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$url

    } else if (grepl("[\u2013:\u2018]", result)) {
      info["title"]     <- str_split(result, " [\u2013:\u2018] ", simplify = TRUE)[,2]
      info["workplace"] <- str_split(str_split(result, " [\u2013:\u2018] ", simplify = TRUE)[,3],
                                     " | ", simplify = TRUE)[,1]
      info["link"]      <- content(httr::GET(url = query_string,
                                             add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$url
    } else
      info <- "error"
  }

  return(info)

}

