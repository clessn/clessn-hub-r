#'
#'
#'
#'
#' @export
configure <- function(url='https://clessn.apps.valeria.science')
{
  username <- getPass::getPass('clessnhub username: ')
  password <- getPass::getPass('clessnhub password: ')
  login(username, password, url)
}

#'
#'
#'
#'
#' @export
login <- function(username, password, url='https://clessn.apps.valeria.science')
{
  suburl <- "/api-token-auth/"
  body <- list(username=username, password=password)
  response <- httr::POST(url=paste0(url, suburl), body=body)
  if (response$status_code != 200)
  {
    stop(paste('failed to configure/login with code', response$status_code))
  }
  token <- httr::content(response)$token
  configuration <<- list(token=token, url=url)
  cat('success')
}

#'
#'
#'
#'
#'
#' @export
call_or_refresh <- function(call)
{
  configuration$token <- refresh_token(configuration$token, configuration$url)
  response <- call()
  if (response$status_code == 403)
  {
      stop('You do not have access to this resource')
  }
  return(response)
}

get_auth_token <- function(username, password, url)
{
  response <- httr::POST(url=paste0(url, '/api-token-auth/'), config=httr::authenticate(username, password))
  if (response$status_code != 200)
  {
    stop('Invalid credentials')
  }
  return(httr::content(response)$token)
}

refresh_token <- function(token, url)
{
  # call /api-token-refresh/ with current token
  response <- httr::POST(url=paste0(url, '/api-token-refresh/'), body=list(token=token))
  if (response$status_code != 200)
  {
    stop('Access has expired, you must login again')
  }
  return(httr::content(response)$token)
}

build_header <- function(token)
{
  return(httr::add_headers(Authorization=paste('Bearer', token)))
}


