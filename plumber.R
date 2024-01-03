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
#* @param db_host Database host
#* @param db_pass Database pass
#* @post /insert
function(table, variable, value, db_host, db_pass) {

  # debug
  # table = "indicators_pra"
  # variable = "pra"
  # value = 1

  # CGS connection
  con <- dbConnect(RPostgres::Postgres(),
                   dbname = "defaultdb",
                   host = db_host,
                   port = 25060L,
                   user = "doadmin",
                   password = db_pass
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
