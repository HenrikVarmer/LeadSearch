# LeadSearch
A small script which utilizes either google or bing's customsearch APIs to fetch likely job titles, workplaces and LinkedIn profile links, given an input dataframe containing names and e-mails. 

### Installing LeadSearch
Install the package directly from github with devtools. Run the first line if you do not currently have devtools installed.

```R
# install.packages('devtools') 
devtools::install_github('HenrikVarmer/LeadSearch')
```
### Using the functions
There's one primary function in this package: lead_search()

To use this function there are some prerequisites: 
* Google CustomSearch API Key
* Google CX Key

If you're new to google customsearch, start here: https://developers.google.com/custom-search/v1/overview

### lead_search()

The lead_search() function takes a dataframe as input in tidy (long) format with one observation (name-email pair) per row. The input data.frame must contain two columns: name and email, and in that particular order (name first, then email)

The lead_search() function returns a dataframe with the names and mails and corresponding best guess for job titles and workplace information along with a likely linkedin profile link. 

Input data structure for conducting a lead search:

| name          | mail               |
| ------------: |-------------------:|
| John Doe      | johndoe@gmai.com   |
| Jane Doe      | janedoe@yahoo.com  |
| Alice         | alice@server.com   |
| Bob           | bob@server.com     |

Usage of the function follows the logic in the following code:
```R
# read in local content + API keys
leads   <- read.csv("leads.csv", sep = ";", stringsAsFactors = FALSE)
api_key <- "your_api_key_here"
cx      <- "your_cx_key_here"

# do lead search
lead_search(leads, api_key, cx)
```
The output from the above example is a dataframe with title, workplace and LinkedIn profile link as new columns attached to the original dataframe. 

| name          | mail               | title            | workplace | linkedin URL |
| ------------: |-------------------:|-----------------:|----------:|-------------:|
| John Doe      | johndoe@gmai.com   | systems engineer | microsoft | https://link |
| Jane Doe      | janedoe@yahoo.com  | astronaut        | space     | https://link |
| Alice         | alice@server.com   | IT supporter     | IT company| https://link |
| Bob           | bob@server.com     | mailman          | US postal | https://link |





