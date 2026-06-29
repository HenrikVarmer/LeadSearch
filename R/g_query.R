#' Query the Google CustomSearch API for a single lead
#'
#' Performs a Google CustomSearch query restricted to \code{linkedin.com} for a
#' single (name, e-mail) pair and returns the best-guess job title, workplace
#' and LinkedIn profile URL.
#'
#' Each candidate URL is fetched \strong{exactly once}; the parsed response is
#' reused for all downstream extraction. Non-200 responses, network errors and
#' empty result sets are handled gracefully and surfaced as \code{"No Result"}
#' rather than raising an error.
#'
#' @param api_key Google CustomSearch API key.
#' @param cx Google CustomSearch engine (context) id.
#' @param name The lead's full name.
#' @param mail The lead's e-mail address.
#' @param delay Seconds to pause before each HTTP request (politeness / rate
#'   limiting). Defaults to \code{0.2}.
#'
#' @return A named character vector with elements \code{title},
#'   \code{workplace} and \code{link}.
#'
#' @importFrom httr GET content status_code
#' @importFrom stringr str_split
#' @importFrom stringi stri_enc_toutf8
#' @importFrom utils URLencode
#' @export
g_query <- function(api_key, cx, name, mail, delay = 0.2) {

  name_enc <- utils::URLencode(stringi::stri_enc_toutf8(name))

  build_url <- function(with_company) {
    query <- paste0("site:linkedin.com+", name_enc)
    if (with_company) {
      query <- paste0(query, "+", extract_company(mail))
    }
    paste0("https://www.googleapis.com/customsearch/v1?key=", api_key,
          "&cx=", cx, "&q=", query)
  }

  use_company <- !is_free_mail(mail)

  item <- g_first_item(build_url(use_company), delay)

  # Fall back to a name-only query if the company-qualified query was empty.
  if (use_company && is.null(item)) {
    item <- g_first_item(build_url(FALSE), delay)
  }

  if (is.null(item) || is.null(item$title)) {
    return(no_result())
  }

  parsed <- parse_google_title(item$title)
  link <- if (!is.null(item$link)) item$link else "No Result"

  c(title = parsed$title, workplace = parsed$workplace, link = link)
}

#' Fetch and return the first Google CustomSearch result item
#'
#' Performs a single HTTP GET against the supplied CustomSearch URL, checks the
#' HTTP status, and returns the first item of the parsed response (or
#' \code{NULL} when the request failed or returned no items).
#'
#' @param url Fully-formed CustomSearch request URL.
#' @param delay Seconds to pause before the request.
#'
#' @return The first result item (a list) or \code{NULL}.
#' @keywords internal
g_first_item <- function(url, delay = 0.2) {
  polite_pause(delay)

  response <- tryCatch(httr::GET(url), error = function(e) NULL)
  if (is.null(response) || httr::status_code(response) != 200L) {
    return(NULL)
  }

  items <- httr::content(response)$items
  if (is.null(items) || length(items) == 0L) {
    return(NULL)
  }

  items[[1]]
}
