# load all packages !!!!!!
library(plumber)
library(httr)
library(jsonlite)
library(mailR)
library(DBI)
library(RPostgres)
library(ibrestr)


#* @apiTitle CGS IB API

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + as.numeric(b)
}

#* Liquidate a position
#* @param accountId:string The account ID for the operation
#* @param symbol:string The symbol to be liquidated
#* @param sectype:string The security type of the symbol
#* @param host:string The host for IB API (default: 'localhost')
#* @param port:integer The port for IB API (default: 5000)
#* @param strategy_name:string Optional strategy name
#* @param email_config:list Optional email configuration
#* @post /liquidate
function(accountId, symbol, sectype, host = "localhost", port = 5000,
         strategy_name = NULL, email_config = list()) {
  # Create an instance of the IB class with the provided parameters
  ib_instance <- IB$new(
    host = host,
    port = port,
    strategy_name = strategy_name,
    email_config = email_config
  )

  # Call the liquidate method
  result <- tryCatch({
    ib_instance$liquidate(accountId, symbol, sectype)
  }, error = function(e) {
    list(error = as.character(e))
  })

  # Return the result
  return(result)
}

#* Set Holdings
#* @param accountId:string The account ID for the operation
#* @param symbol:string The symbol to be liquidated
#* @param sectype:string The security type of the symbol
#* @param side:string The size of the trade. Can be BUY or SELL
#* @param tif:string  The Time-In-Force. Valid Values: GTC, OPG, DAY, IOC, PAX (CRYPTO ONLY).
#* @param weight:numeric Numeric, required, portfolio weight.
#* @param host:string The host for IB API (default: 'localhost')
#* @param port:integer The port for IB API (default: 5000)
#* @param strategy_name:string Optional strategy name
#* @param email_config:list Optional email configuration
#* @post /set_holdings
function(accountId, symbol, sectype, side , tif, weight,
         host = "localhost", port = 5000, strategy_name = NULL,
         email_config = list()) {
  # Create an instance of the IB class with the provided parameters
  ib_instance <- IB$new(
    host = host,
    port = port,
    strategy_name = strategy_name,
    email_config = email_config
  )

  # Call the liquidate method
  result <- tryCatch({
    ib_instance$set_holdings(accountId, symbol, sectype, side, tif, weight)
  }, error = function(e) {
    list(error = as.character(e))
  })

  # Return the result
  return(result)
}

#* Indicator webhook
#* @param table Table name to save data to
#* @param variable Variable name
#* @param value Value to save
#* @post /insert
function(table, variable, value) {

  # debug
  # table = "indicators_pra"
  # variable = "pra"
  # value = 1

  # CGS connection
  con <- dbConnect(RPostgres::Postgres(),
                   dbname = "defaultdb",
                   host = "db-postgresql-fra1-54406-do-user-13776848-0.c.db.ondigitalocean.com",
                   port = 25060L,
                   user = "doadmin",
                   password = "AVNS_7h0PktF6BbOHWOUK45K"
  )

  # check if loging table exists. If it doesn't exists create logging table.
  if (!(DBI::dbExistsTable(con, table))) {

    # create new table
    df = data.frame(
      timestamp = .POSIXct(0L, tz = "UTC"),
      variable = character(1),
      value = numeric(1)
    )
    dbWriteTable(con, table, value = df, overwrite = TRUE, append = FALSE,
                 row.names = FALSE)
  }

  # insert data to db
  RPostgres::dbSendQuery(
    con,
    paste0("INSERT INTO ", table, " (timestamp,variable,value) VALUES ($1,$2,$3);"),
    list(Sys.time(), variable, value)
  )
  dbDisconnect(con)
  return(1)
}

######### DEBUG: check if order exists ##########
# orders <- ib_get(paste0(domain, ":", port, "/v1/api/iserver/account/orders"))
# # ib get template
# ib_delete = function(url = paste0(domain, ":", port, "/v1/api/sso/validate"),
#                      query = NULL) {
#   p <- RETRY("GET",
#              url,
#              add_headers('User-Agent' = 'Console',
#                          'content-type' = 'application/json'),
#              config = httr::config(ssl_verifypeer = FALSE, ssl_verifyhost = FALSE),
#              query = query,
#              times = 5L)
#   x <- content(p)
#   return(x)
# }
# cancel_order <- ib_delete(paste0(domain, ":", port, "/v1/api/iserver/account/", account_id, "/order/", orders$orders[[1]]$orderId))
######### DEBUG: check if order exists ##########

# crete container registry
# az acr build -g Strategies --image livealgos:v2 --registry cgsqcwebhook --file Dockerfile .


# # db table
# connec <- dbConnect(RPostgres::Postgres(),
#                     dbname = "defaultdb",
#                     host = "db-postgresql-fra1-02794-do-user-8031900-0.b.db.ondigitalocean.com",
#                     port = 25060L,
#                     user = "doadmin",
#                     password = "AVNS_5qn9VrZkXntvZnQNsSm"
# )
# DBI::dbListTables(connec)
# table_ = dbReadTable(connec, "indicators_minmax")
# dbDisconnect(connec)
