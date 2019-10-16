

b_query <- function(b_api_key, b_cx, name, mail) {

  name_origi <- name
  company    <- gsub(".*@|\\..*", "", mail)
  name_clean <- gsub("[-–—]", " ", name)
  name       <- URLencode(stri_enc_toutf8(name))
  info       <- c()

  if (any(grepl(tolower(company), c("gmail", "hotmail", ""))) | mail == "" | company = "") {
    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%2Fin%2F%20",
                          name, "&customconfig=", b_cx, "&mkt=da-DK", sep = "")
  } else {

    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%2Fin%2F%20",
                          name, "%20", company, "&customconfig=", b_cx, "&mkt=da-DK", sep = "")

    if (is.null(content(httr::GET(url = query_string,
                                  add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$name)) {

    query_string <- paste("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=site%3Alinkedin.com%2Fin%2F%20",
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

    if(str_replace(name_origi, "\\p{Pd}", "GARBAGEDATA") != name_origi) {

    temp_cle <- str_replace(result,
      str_split(
        result, "\\p{Pd}", simplify = TRUE)[,1], replacement = "")

    result <- str_sub(temp_cle, 2)
    }

    info["link"]      <- content(httr::GET(url = query_string,
                                            add_headers("Ocp-Apim-Subscription-Key" = b_api_key)))$webPages$value[[1]]$url
    err_check_title   <- textclean::replace_incomplete(
      try(str_split(result, "\\p{Pd}", simplify = TRUE)[,2], silent = TRUE), replace = "")
    err_check_work    <- textclean::replace_incomplete(
      try(str_split(result, "\\p{Pd}", simplify = TRUE)[,3], silent = TRUE), replace = "")

    if (class(err_check_work) == "try-error") {
      info["workplace"] <- "error"

    } else
      info["workplace"] <- textclean::replace_incomplete(
        str_split(result, "\\p{Pd}", simplify = TRUE)[,3], replacement = "")

    if (class(err_check_title) == "try-error") {
       info["title"] <- "error"

    } else
      info["title"] <- textclean::replace_incomplete(
      str_split(result, "\\p{Pd}", simplify = TRUE)[,2], replacement = "")

  }

  if(grepl("LinkedIn", info["workplace"])) {
    info["workplace"] <- str_replace(info["workplace"], "LinkedIn", replacement = "")
    info["workplace"] <- str_replace(info["workplace"], "linkedin", replacement = "")
  }
  if(grepl("LinkedIn", info["title"])) {
    info["title"] <- str_replace(info["title"], "LinkedIn", replacement = "")
    info["title"] <- str_replace(info["title"], "linkedin", replacement = "")
  }

  return(info)
}


