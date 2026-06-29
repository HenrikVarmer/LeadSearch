#' Enrich a data frame of leads with job, workplace and LinkedIn information
#'
#' For each (name, e-mail) pair in \code{x}, queries the chosen search engine's
#' CustomSearch API (restricted to LinkedIn) and appends three columns
#' containing the best-guess job \code{title}, \code{workplace} and LinkedIn
#' profile \code{link}.
#'
#' @param x A data frame (or object coercible to one) whose \strong{first
#'   column is the lead's name} and \strong{second column is the lead's
#'   e-mail}, in that order.
#' @param engine The search engine to use: either \code{"google"} (the default)
#'   or \code{"bing"}.
#' @param api_key The CustomSearch API key for the chosen engine.
#' @param cx The CustomSearch engine / configuration id for the chosen engine.
#' @param delay Seconds to pause before each HTTP request, to respect API rate
#'   limits. Defaults to \code{0.2}.
#'
#' @return \code{x} with three additional character columns: \code{title},
#'   \code{workplace} and \code{link}.
#'
#' @examples
#' \dontrun{
#' leads <- data.frame(
#'   name = c("Jane Doe", "John Doe"),
#'   mail = c("jane@acme.com", "john@gmail.com"),
#'   stringsAsFactors = FALSE
#' )
#' lead_search(x = leads, api_key = "YOUR_KEY", cx = "YOUR_CX")
#' }
#'
#' @export
lead_search <- function(x, engine = c("google", "bing"), api_key, cx,
                       delay = 0.2) {

  engine <- match.arg(engine)
  x <- as.data.frame(x, stringsAsFactors = FALSE)

  query_fun <- switch(engine,
                      google = g_query,
                      bing   = b_query)

  name <- x[, 1]
  mail <- x[, 2]

  info <- mapply(query_fun, api_key, cx, name, mail,
                MoreArgs = list(delay = delay))
  info <- as.data.frame(info, stringsAsFactors = FALSE)

  x$title     <- as.character(unlist(info["title", ],     use.names = FALSE))
  x$workplace <- as.character(unlist(info["workplace", ], use.names = FALSE))
  x$link      <- as.character(unlist(info["link", ],      use.names = FALSE))

  x
}
