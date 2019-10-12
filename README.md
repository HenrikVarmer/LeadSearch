# lead_search
Utilizes google's customsearch API to fetch likely job titles, workplaces and LinkedIn profile links, given an input dataframe containing names and e-mails

### Installing lead_search
Install the package directly from github with devtools. Run the first line if you do not currently have devtools installed.

```R
# install.packages('devtools') 
devtools::install_github('HenrikVarmer/lead_search')
```
### Using the functions
There's one primary function in this package: lead_search()

### lead_search()

The lead_search() function takes a dataframe as input in tidy (long) format with one observation (name-email pair) per row. The input data.frame must contain two columns: name and email. The data.frame and column names are provided as arguments to the function.

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
conf    <- read.csv("api_key.csv", sep = ";", stringsAsFactors = FALSE)[1,]
api_key <- conf$api_key
cx      <- conf$cx


lead_search(leads, api_key, cx)
```
The output from the above example is a dataframe with title, workplace and LinkedIn profile link as new columns attached to the original dataframe. 

| name          | mail               | title            | workplace |
| ------------: |-------------------:|-----------------:|----------:|
| John Doe      | johndoe@gmai.com   | systems engineer | microsoft |
| Jane Doe      | janedoe@yahoo.com  | astronaut        | space     |
| Alice         | alice@server.com   | IT supporter     | IT company|
| Bob           | bob@server.com     | mailman          | US postal |





