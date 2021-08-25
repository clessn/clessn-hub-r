#'
#' @export
http_get <- function(path, options=NULL, verify=T)
{
  if (!is.null(options))
  {
    params <- paste(names(options), options, sep="=", collapse='&')
    params <- paste0("?", params)
  }
  else
  {
    params <- ""
  }
  token <- hub_config$token
  token_prefix <- hub_config$token_prefix
  response <- httr::GET(url=paste0(hub_config$url, path, params), config=httr::add_headers(Authorization=paste(token_prefix, token)), verify=verify)

  if (response$status_code >= 500)
  {
    stop("Une erreur s'est produite sur le hub. Contactez un administrateur.")
  }

  return(response)
}

#'
#' @export
http_delete <- function(path, verify=T)
{
  token <- hub_config$token
  token_prefix <- hub_config$token_prefix
  response <- httr::DELETE(url=paste0(hub_config$url, path), config=httr::add_headers(Authorization=paste(token_prefix, token)), verify=verify)

  if (response$status_code >= 500)
  {
    stop("Une erreur s'est produite sur le hub. Contactez un administrateur.")
  }

  return(response)
}

#'
#' @export
http_update <- function(path, body, verify=T)
{
  if (!is.null(body$data))
  {
    body$data[sapply(body$data,is.null)] <- NA_character_
  }

  if (!is.null(body$metadata))
  {
    body$metadata[sapply(body$metadata,is.null)] <- NA_character_
  }
  token <- hub_config$token
  token_prefix <- hub_config$token_prefix
  response <- httr::PATCH(url=paste0(hub_config$url, path), body=body, config=httr::add_headers(Authorization=paste(token_prefix, token)), verify=verify)
  return(response)
}

#'
#' @export
http_post <- function(path, body, options=NULL, verify=T)
{
  if (!is.null(body$data))
  {
    body$data[sapply(body$data,is.null)] <- NA_character_
  }

  if (!is.null(body$metadata))
  {
    body$metadata[sapply(body$metadata,is.null)] <- NA_character_
  }

  if (!is.null(options))
  {
    params <- paste0(names(options), options, sep="=", collapse='&')
    params <- paste0("?", params)
  }
  else
  {
    params <- ""
  }
  token <- hub_config$token
  token_prefix <- hub_config$token_prefix
  response <- httr::POST(url=paste0(hub_config$url, path, params), body=body, config=httr::add_headers(Authorization=paste(token_prefix, token)), verify=verify)
  return(response)
}
