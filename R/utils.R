#' Built-in free / ISP mail provider labels
#'
#' A small set of provider \emph{labels} (the part of the domain before the
#' first dot) that are treated as free or ISP webmail providers. When a lead's
#' e-mail belongs to one of these, the company name carries no signal and is
#' therefore not appended to the search query.
#'
#' This list is used in addition to the comprehensive domain list shipped in
#' \code{inst/extdata/free_mail_providers.txt} (see
#' \code{\link{free_mail_providers}}).
#'
#' @return A character vector of provider labels.
#' @keywords internal
builtin_free_mail_labels <- function() {
  c("gmail", "hotmail", "yahoo", "outlook", "live", "icloud", "msn",
    "jubii", "netmail", "stofanet", "post", "mail", "")
}

#' Read the bundled list of free mail provider domains
#'
#' Reads the comprehensive list of free / disposable webmail domains shipped
#' with the package in \code{inst/extdata/free_mail_providers.txt}. The result
#' is memoised so the file is only read from disk once per session.
#'
#' @return A lower-cased character vector of mail domains. Returns an empty
#'   character vector if the data file cannot be located (for example when the
#'   package is not installed).
#' @export
free_mail_providers <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) {
      return(cache)
    }
    path <- system.file("extdata", "free_mail_providers.txt",
                        package = "leadsearch")
    providers <- if (nzchar(path)) {
      tolower(trimws(readLines(path, warn = FALSE)))
    } else {
      character(0)
    }
    cache <<- providers
    providers
  }
})

#' Extract the company label from an e-mail address
#'
#' Returns the portion of the domain between the \code{@@} and the first dot,
#' e.g. \code{"acme"} for \code{"jane@acme.com"}. This is used as a coarse
#' company identifier when building search queries.
#'
#' @param mail A character scalar e-mail address.
#'
#' @return A character scalar company label (possibly \code{""}).
#' @export
extract_company <- function(mail) {
  if (length(mail) == 0L || is.na(mail)) {
    return("")
  }
  gsub(".*@|\\..*", "", mail)
}

#' Extract the full domain from an e-mail address
#'
#' @param mail A character scalar e-mail address.
#'
#' @return A lower-cased character scalar domain (e.g. \code{"acme.com"}), or
#'   \code{""} when no domain is present.
#' @export
extract_domain <- function(mail) {
  if (length(mail) == 0L || is.na(mail)) {
    return("")
  }
  tolower(trimws(sub(".*@", "", mail)))
}

#' Is an e-mail address from a free / ISP mail provider?
#'
#' Determines whether an e-mail address belongs to a free, ISP or disposable
#' webmail provider. Such addresses carry no useful company signal, so the
#' company name is omitted from the generated search query.
#'
#' @param mail A character scalar e-mail address.
#' @param providers A character vector of free-mail domains to check the full
#'   domain against. Defaults to \code{\link{free_mail_providers}()}.
#' @param labels A character vector of free-mail provider labels to check the
#'   company label against. Defaults to \code{builtin_free_mail_labels()}.
#'
#' @return \code{TRUE} if the address is empty or matches a free-mail provider,
#'   otherwise \code{FALSE}.
#' @export
is_free_mail <- function(mail,
                        providers = free_mail_providers(),
                        labels = builtin_free_mail_labels()) {
  if (length(mail) == 0L || is.na(mail) || !nzchar(mail)) {
    return(TRUE)
  }
  domain <- extract_domain(mail)
  if (!nzchar(domain)) {
    return(TRUE)
  }
  company <- extract_company(mail)
  tolower(company) %in% labels || domain %in% providers
}

#' A "No Result" record
#'
#' Convenience constructor for the named character vector returned by the query
#' functions when no usable result is found.
#'
#' @return A named character vector with \code{title}, \code{workplace} and
#'   \code{link} all set to \code{"No Result"}.
#' @keywords internal
no_result <- function() {
  c(title = "No Result", workplace = "No Result", link = "No Result")
}

#' Parse a Google CustomSearch LinkedIn result title
#'
#' LinkedIn result titles returned by Google CustomSearch typically follow the
#' pattern \code{"Name - Job Title - Workplace | LinkedIn"}. This helper splits
#' such a title into its job-title and workplace components. It is a pure
#' function (no network access) so it can be unit-tested in isolation.
#'
#' @param result A character scalar result title.
#'
#' @return A named list with character scalars \code{title} and
#'   \code{workplace}. When the title cannot be parsed both elements are set to
#'   \code{"error"}.
#' @export
parse_google_title <- function(result) {
  if (length(result) == 0L || is.na(result) || !nzchar(result)) {
    return(list(title = "error", workplace = "error"))
  }

  split_on <- function(sep) {
    parts <- stringr::str_split(result, sep, simplify = TRUE)
    title <- if (ncol(parts) >= 2L) parts[, 2] else ""
    workplace <- if (ncol(parts) >= 3L) {
      stringr::str_split(parts[, 3], " \\| ", simplify = TRUE)[, 1]
    } else {
      ""
    }
    list(title = title, workplace = workplace)
  }

  if (grepl(" - ", result, fixed = TRUE)) {
    split_on(" - ")
  } else if (grepl("[\u2013:\u2015]", result)) {
    split_on(" [\u2013:\u2015] ")
  } else {
    list(title = "error", workplace = "error")
  }
}

#' Pause politely between API requests
#'
#' Sleeps for the requested number of seconds to respect API rate limits. A
#' \code{delay} of \code{0} (or less) is a no-op.
#'
#' @param delay Number of seconds to sleep.
#'
#' @return Invisibly \code{NULL}.
#' @keywords internal
polite_pause <- function(delay) {
  if (is.numeric(delay) && length(delay) == 1L && !is.na(delay) && delay > 0) {
    Sys.sleep(delay)
  }
  invisible(NULL)
}
