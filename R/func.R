#' @export
configure <- function(url='https://clessn.apps.valeria.science')
{
  cat('configuring...\n')
    result <- list()
    result$url <- url

    username <- readline(prompt='Username: ')
    password <- getPass::getPass('Password: ')
    cat('logging in...\n')
    response <- httr::POST(url=paste0(url, '/jwtauth/request/'), config=httr::authenticate(username, password))
    if (response$status_code != 200)
    {
      stop(paste('failed to configure/login with code', response$status_code))
    }
    content <- httr::content(response)
    result$token <- content$access
    result$refresh <- content$refresh
    result$access_header <- httr::add_headers(Authorization=paste('Bearer', result$token))
    result$refresh_header <- httr::add_headers(Authorization=paste('Bearer', result$refresh))
    cat('Successfully logged in\n')
    config <<- result
    return(result)
}

refresh <- function()
{
  cat('refreshing token...\n')
  response <- httr::POST(url=paste0(config$url, '/jwtauth/refresh/'), config=config$refresh_header)
  if (response$status_code != 200)
  {
    stop(paste('Could not refresh token. Please login again by executing configure(). ', response$status_code))
  }
  content <- httr::content(response)
  c <- list()
  c$url <- config$url
  c$token <- content$access
  c$refresh <- content$refresh
  c$access_header <- httr::add_headers(Authorization=paste('Bearer', c$token))
  c$refresh_header <- httr::add_headers(Authorization=paste('Bearer', c$refresh))
  config <<- c

  response <- httr::GET(url=paste0(config$url, '/jwtauth/test_access/'), config=config$access_header)
  if (response$status_code != 200)
  {
    stop(paste('Failed test of access token. ', response$status_code))
  }

  response <- httr::GET(url=paste0(config$url, '/jwtauth/test_refresh/'), config=config$refresh_header)
  if (response$status_code != 200)
  {
    stop(paste('Failed test of refresh token. ', response$status_code))
  }


  cat('token refreshed\n')
}


download <- function(table)
{
  url <- paste0(config$url, '/data/', table)
  start_time <- Sys.time()
  response <- httr::GET(url=url, config=config$access_header)

  if (response$status_code != 200)
  {
    if (response$status_code == 401)
    {
      refresh()
      response <- httr::GET(url=url, config=config$access_header)
      print(response$status_code)
    }
    else if (response$status_code == 403)
    {
      stop('you are now allowed to access this table.')
    }
    else
    {
      stop(paste('Could not find table.', response$status_code))
    }
  }
  content <- httr::content(response)
  result <- list()
  item_count <- content$count
  next_page <- url
  items <- content$results
  cat(paste('found',item_count,'items\n'))
  current_count <- 0
  data <- NULL

  while (current_count != item_count)
  {
    result <- loadPage(next_page, data)
    data <- result$data
    next_page <- result$next_page
    current_count = nrow(data)
    cat(paste0('\r',current_count, '/', item_count, '...', percent(current_count/item_count), '        '))
    if (is.null(result$next_page))
    {
      break
    }
  }

  for (col in colnames(data))
  {
    if (typeof(data[[col]]) == 'character')
    {
      Encoding(data[[col]]) <- "UTF-8"
    }
  }

  end_time <- Sys.time()
  cat('\nsuccess with a ')
  print(end_time - start_time)

  final_result <- list()
  final_result$df <- data
  final_result$date <- Sys.time()
  final_result$table <- table

  return(final_result)
}

loadPage <- function(url, data=NULL)
{
  response <- httr::GET(url=url, config=config$access_header)
  if (response$status_code != 200)
  {
    if (response$status_code == 401)
    {
      refresh()
      response <- httr::GET(url=url, config=config$access_header)
    }
    else
    {
      stop(paste('download failed during process with code'), response$status_code)
    }
  }
  content <- httr::content(response)
  items <- content$results
  next_page <- content$'next'

  result <- suppressWarnings(data.table::rbindlist(items))
  if (is.null(data))
  {
    data <- result
  }
  else
  {
    data <- rbind(data, result)
  }
  return(list(data=data, next_page=next_page))
}
