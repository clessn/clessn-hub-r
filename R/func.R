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

refresh_token <- function()
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

#' @export
upload <- function(tablename, object)
{
  url <- paste0(config$url, '/data/', tablename, '/')
  start_time <- Sys.time()
  response <- httr::POST(url=url, body=object, config=config$access_header)
  if (response$status_code != 201)
  {
    if (response$status_code == 400)
    {
      stop('either something failed terribly in the package or object is already online.')
    }
    else if (response$status_code == 401)
    {
      #stop('Execute configure again or refresh_token().')
      refresh_token()
      response <- httr::GET(url=url, config=config$access_header)
    }
    else if (response$status_code == 403)
    {
      stop('You do not have access to this table.')
    }
    else
    {
      stop(paste('Could not put object for an unknown reason. Error code ', response$status_code))
    }
  }
  end_time <- Sys.time()
  cat('\nsuccess with a ')
  print(end_time - start_time)
}

#' @export
update <- function(tablename, uuid, data)
{
  url <- paste0(config$url, '/data/', tablename, '/', uuid, '/')
  start_time <- Sys.time()
  response <- httr::PATCH(url=url, config=config$access_header, body=data)

  if (response$status_code != 200)
  {
    if (response$status_code == 404)
    {
      stop('The object does not exist.')
    }
    else if (response$status_code == 401)
    {
      #stop('Execute configure again or refresh_token().')
      refresh_token()
      response <- httr::GET(url=url, config=config$access_header)
    }
    else if (response$status_code == 403)
    {
      stop('You do not have access to this table.')
    }
    else
    {
      print(response)
      stop(paste('Could not put object for an unknown reason. Error code ', response$status_code))
    }
  }

  end_time <- Sys.time()
  cat('\nsuccess with a ')
  print(end_time - start_time)
}

#' @export
delete <- function(tablename, uuid)
{
  url <- paste0(config$url, '/data/', tablename, '/', uuid)
  start_time <- Sys.time()
  response <- httr::DELETE(url=url, config=config$access_header)

  if (response$status_code != 204)
  {
    if (response$status_code == 400)
    {
      stop('either something failed terribly in the package or object does not exist.')
    }
    else if (response$status_code == 401)
    {
      #stop('Execute configure again or refresh_token().')
      refresh_token()
      response <- httr::GET(url=url, config=config$access_header)
    }
    else if (response$status_code == 403)
    {
      stop('You do not have access to this table.')
    }
    else
    {
      stop(paste('Could not delete object for an unknown reason. Error code ', response$status_code))
    }
  }

  end_time <- Sys.time()
  cat('\nsuccess with a ')
  print(end_time - start_time)
}

#' @export
download <- function(tablename)
{
  return(load(config$url, tablename, '', config$access_header, NULL))
}

#' @export
refresh <- function(data)
{
  return(load(config$url, data$table, paste0('modified=', data$date), config$access_header, data))
}

load <- function(base_url, tablename, params, token, return_object)
{
  url <- paste0(base_url, '/data/', tablename, '/?', params)
  start_time <- Sys.time()

  # Download the first page and report the error if any
  response <- httr::GET(url=url, config=token)
  if (response$status_code != 200)
  {
    if (response$status_code == 401)
    {
      #stop('Execute configure again.')
      refresh_token()
      response <- httr::GET(url=url, config=config$access_header)
    }
    else if (response$status_code == 403)
    {
      stop('You do not have access to this table.')
    }
    else
    {
      stop(paste('Could not load table for an unknown reason. Error code ', response$status_code))
    }
  }

  # Initialize the content and the variables
  content <- httr::content(response)
  result <- list()
  item_count <- content$count
  next_page <- url
  items <- content$results
  cat(paste('found',item_count,'items\n'))
  current_count <- 0
  data <- NULL

  # Load all pages one after this other. If the next_page is null, stop.
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

  # make sure all columns are UTF-8
  for (col in colnames(data))
  {
    if (typeof(data[[col]]) == 'character')
    {
      Encoding(data[[col]]) <- "UTF-8"
    }
  }

  # Report time to download
  end_time <- Sys.time()
  cat('\nsuccess with a ')
  print(end_time - start_time)

  # Create or update result object
  if (is.null(return_object))
  {
    final_result <- list()
    final_result$df <- data
    final_result$date <- format(Sys.time(), "%Y-%m-%d")
    final_result$table <- tablename

    return(final_result)
  }
  else
  {
    return_object$df <- merge_data(data.table::setDT(return_object$df), data.table::setDT(data))
    return_object$date <- format(Sys.time(), "%Y-%m-%d")
    return(return_object)
  }

}

merge_data <- function(all_data, new_data)
{
  result <- sqldf::sqldf("SELECT * FROM all_data UNION ALL SELECT * FROM new_data");
  result <- result[order(result[["modified"]], decreasing = TRUE), ]
  return(result[!duplicated(result$uuid), ])
}

loadPage <- function(url, data=NULL)
{
  response <- httr::GET(url=url, config=config$access_header)
  if (response$status_code != 200)
  {
    if (response$status_code == 401)
    {
      refresh_token()
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
