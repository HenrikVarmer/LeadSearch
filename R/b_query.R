#' Query the Bing CustomSearch API for a single lead
#'
#' Performs a Bing CustomSearch query restricted to \code{linkedin.com/in/} for
#' a single (name, e-mail) pair and returns the best-guess job title, workplace
#' and LinkedIn profile URL.
#'
#' As with \code{\link{g_query}}, each candidate URL is fetched \strong{exactly
#' once} and the parsed response is reused. Non-200 responses, network errors
#' and empty result sets are surfaced as \code{"No Result"} rather than raising
#' an error.
#'
#' @param api_key Bing CustomSearch subscription key (sent as the
#'   \code{Ocp-Apim-Subscription-Key} header).
#' @param cx Bing CustomSearch custom configuration id.
#' @param name The lead's full name.
#' @param mail The lead's e-mail address.
#' @param delay Seconds to pause before each HTTP request (politeness / rate
#'   limiting). Defaults to \code{0.2}.
#'
#' @return A named character vector with elements \code{title},
#'   \code{workplace} and \code{link}.
#'
#' @importFrom httr GET content status_code add_headers
#' @importFrom stringr str_split str_replace str_sub
#' @importFrom stringi stri_enc_toutf8
#' @importFrom utils URLencode
#' @export
b_query <- function(api_key, cx, name, mail, delay = 0.2) {

  name_origi <- name
  name_enc   <- utils::URLencode(stringi::stri_enc_toutf8(name))

  build_url <- function(with_company) {
    query <- paste0("site%3Alinkedin.com%2Fin%2F%20", name_enc)
    if (with_company) {
      query <- paste0(query, "%20", extract_company(mail))
    }
    paste0("https://api.cognitive.microsoft.com/bingcustomsearch/v7.0/search?q=",
          query, "&customconfig=", cx, "&mkt=da-DK")
  }

  use_company <- !is_free_mail(mail)

  page <- b_first_page(build_url(use_company), api_key, delay)

  if (use_company && is.null(page)) {
    page <- b_first_page(build_url(FALSE), api_key, delay)
  }

  if (is.null(page) || is.null(page$name)) {
    return(no_result())
  }

  parsed <- parse_bing_title(page$name, name_origi)
  link <- if (!is.null(page$url)) page$url else "No Result"

  c(title = parsed$title, workplace = parsed$workplace, link = link)
}

#' Fetch and return the first Bing CustomSearch web page result
#'
#' Performs a single authenticated HTTP GET against the supplied Bing
#' CustomSearch URL, checks the HTTP status, and returns the first web page
#' result of the parsed response (or \code{NULL} when the request failed or
#' returned no results).
#'
#' @param url Fully-formed CustomSearch request URL.
#' @param api_key Bing subscription key.
#' @param delay Seconds to pause before the request.
#'
#' @return The first web page result (a list) or \code{NULL}.
#' @keywords internal
b_first_page <- function(url, api_key, delay = 0.2) {
  polite_pause(delay)

  response <- tryCatch(
    httr::GET(url, httr::add_headers("Ocp-Apim-Subscription-Key" = api_key)),
    error = function(e) NULL)

  if (is.null(response) || httr::status_code(response) != 200L) {
    return(NULL)
  }

  value <- httr::content(response)$webPages$value
  if (is.null(value) || length(value) == 0L) {
    return(NULL)
  }

  value[[1]]
}

#' Strip "LinkedIn" mentions from a string
#'
#' @param x A character scalar.
#' @return \code{x} with any (case-insensitive) occurrence of "linkedin"
#'   removed and surrounding whitespace trimmed.
#' @importFrom stringr str_replace_all
#' @keywords internal
strip_linkedin <- function(x) {
  if (length(x) == 0L || is.na(x)) {
    return(x)
  }
  trimws(stringr::str_replace_all(x, "(?i)linkedin", ""))
}

#' Parse a Bing CustomSearch LinkedIn result title
#'
#' Bing result titles for LinkedIn profiles typically follow the pattern
#' \code{"Name - Job Title - Workplace"} (using any kind of dash). This helper
#' splits such a title into its job-title and workplace components, taking care
#' to first strip the lead's own name when that name itself contains a dash. It
#' is a pure function (no network access) so it can be unit-tested in isolation.
#'
#' @param result A character scalar result title.
#' @param name The lead's original (un-encoded) name; used to detect and strip
#'   dashed names. Defaults to \code{""}.
#'
#' @return A named list with character scalars \code{title} and
#'   \code{workplace}. Components that cannot be parsed are set to
#'   \code{"error"}.
#'
#' @importFrom stringr str_split str_replace str_sub
#' @importFrom textclean replace_incomplete
#' @export
parse_bing_title <- function(result, name = "") {
  if (length(result) == 0L || is.na(result) || !nzchar(result)) {
    return(list(title = "error", workplace = "error"))
  }

  # If the lead's own name contains a dash, the leading name segment of the
  # result title is mis-split; strip it before parsing.
  if (grepl("\\p{Pd}", name, perl = TRUE)) {
    leading <- stringr::str_split(result, "\\p{Pd}", simplify = TRUE)[, 1]
    cleaned <- stringr::str_replace(result, leading, replacement = "")
    result  <- stringr::str_sub(cleaned, 2)
  }

  parts <- stringr::str_split(result, "\\p{Pd}", simplify = TRUE)

  title <- if (ncol(parts) >= 2L) {
    strip_linkedin(textclean::replace_incomplete(parts[, 2], replace = ""))
  } else {
    "error"
  }
  workplace <- if (ncol(parts) >= 3L) {
    strip_linkedin(textclean::replace_incomplete(parts[, 3], replace = ""))
  } else {
    "error"
  }

  list(title = title, workplace = workplace)
}
