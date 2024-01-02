library(httr)


# Define the data to be sent in the request body
data <- list(
  accountId = "your_account_id",
  symbol = "AAPL",
  sectype = "CFD",
  host = "cgsliveexuber2.eastus.azurecontainer.io",
  port = 5000,
  strategy_name = "Exuber 2",
  email_config = list(
    email_from = "mislav.sagovac@contentio.biz",
    email_to = "mislav.sagovac@contentio.biz",
    smtp_host = "mail.contentio.biz",
    smtp_port = 587,
    smtp_user = "mislav.sagovac@contentio.biz",
    smtp_password = "s8^t5?}r-x&Q"
  )
)

# Make the POST request
url <- "http://localhost:8000/liquidate"
response <- POST(url, body = data, encode = "json")

# Check the response
content(response, "text")

