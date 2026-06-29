# LeadSearch

<!-- badges: start -->
[![R-CMD-check](https://github.com/HenrikVarmer/LeadSearch/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/HenrikVarmer/LeadSearch/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

An R package which utilizes either Google's or Bing's CustomSearch APIs to fetch likely job titles, workplaces and LinkedIn profile links, given an input dataframe containing names and e-mails.

Each candidate query is fetched **once** (reusing the parsed response), HTTP errors and empty results are handled gracefully as `"No Result"`, and a small politeness delay is applied between requests to respect API rate limits.

### Installing LeadSearch
Install the package directly from github with devtools. Run the first line if you do not currently have devtools installed.

```R
# install.packages('devtools') 
devtools::install_github('HenrikVarmer/LeadSearch')
```
### Using the functions
There's one primary function in this package: lead_search()

To use this function there are some prerequisites: 
* Google / Bing CustomSearch API Key
* Google / Bing Context Key

If you're new to google customsearch, start here: https://developers.google.com/custom-search/v1/overview

### lead_search()

The lead_search() function takes a dataframe as input in tidy (long) format with one observation (name-email pair) per row. The input data.frame must contain two columns: name and email, and in that particular order (name first, then email)

The lead_search() function returns a dataframe with the names and mails and corresponding best guess for job titles and workplace information along with a likely linkedin profile link. 

Input data structure for conducting a lead search:

| name          | mail               |
| ------------: |-------------------:|
| John Doe      | johndoe@gmail.com  |
| Jane Doe      | janedoe@yahoo.com  |
| Alice         | alice@server.com   |
| Bob           | bob@server.com     |

The function signature is:

```R
lead_search(x, engine = c("google", "bing"), api_key, cx, delay = 0.2)
```

Because `engine` is the second argument, **always pass `api_key` and `cx` by name** so they don't accidentally bind to `engine`:

```R
# read in local content + API keys
leads   <- read.csv("leads.csv", sep = ";", stringsAsFactors = FALSE)

# do a lead search (Google is the default engine)
result <- lead_search(x = leads, api_key = "your_api_key_here", cx = "your_cx_key_here")

# or use Bing
result <- lead_search(x = leads, engine = "bing", api_key = "your_api_key_here", cx = "your_cx_key_here")
```
The output from the above example is a dataframe with `title`, `workplace` and `link` (the LinkedIn profile URL) as new columns attached to the original dataframe.

| name          | mail               | title            | workplace | link         |
| ------------: |-------------------:|-----------------:|----------:|-------------:|
| John Doe      | johndoe@gmail.com  | systems engineer | microsoft | https://link |
| Jane Doe      | janedoe@yahoo.com  | astronaut        | space     | https://link |
| Alice         | alice@server.com   | IT supporter     | IT company| https://link |
| Bob           | bob@server.com     | mailman          | US postal | https://link |





