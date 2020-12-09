#'
#'
#' @export
fetch_tablenames <- function()
{
  suburl <- "/data/"
  url <- configuration$url

  response <- call_or_refresh(function()
  {
    return(httr::GET(url=paste0(url, suburl), config=build_header(configuration$token)))
  })
  if (response$status_code != 200)
  {
    cat(response$status_code)
    stop('an error occured in fetch_tablenames. Contact an administrator.')
  }
  tables <- httr::content(response)
  cat('success/n')
  return(names(tables))
}

#'
#'
#' @export
fetch_tableschema <- function(tablename)
{
  # somehow find a way to return the fields of the specified table
  stop('not implemented')
}

#' return whether the specified uuid is in tablename
#'
#' @export
item_exists <- function(uuid, tablename)
{
  suburl <- paste0("/data/", tablename, "/", uuid, "/")
  url <- configuration$url

  response <- call_or_refresh(function()
  {
    return(httr::GET(url=paste0(url, suburl), config=build_header(configuration$token)))
  })
  if (response$status_code == 404)
  {
    return(FALSE)
  }
  else if(response$status_code == 200)
  {
    return(TRUE)
  }
  else
  {
    stop(paste0('item_exists failed with error code ', response$status_code))
  }
}

#' delete the item uuid in tablename
#'
#' @export
delete_item <- function(uuid, tablename)
{
  suburl <- paste0("/data/", tablename, "/", uuid, "/")
  url <- configuration$url

  response <- call_or_refresh(function()
  {
    return(httr::DELETE(url=paste0(url, suburl), config=build_header(configuration$token)))
  })
  if (response$status_code == 404)
  {
    stop('Cannot delete item. It does not exist')
  }
  else if(response$status_code == 204)
  {
    cat('success/n')
  }
  else
  {
    stop(paste0('delete_item failed with error code ', response$status_code))
  }
}

#' return the specified uuid from tablename
#'
#' @export
get_item <- function(uuid, tablename)
{
  suburl <- paste0("/data/", tablename, "/", uuid, "/")
  url <- configuration$url
  response <- call_or_refresh(function()
  {
    return(httr::GET(url=paste0(url, suburl), config=build_header(configuration$token)))
  })
  if (response$status_code != 200)
  {
    stop(paste0('get_item failed with error code ', response$status_code))
  }
  cat('success/n')
  return(httr::content(response))
}

#'
#'
#' @export
download_table <- function(tablename)
{
  suburl <- paste0("/data/", tablename, "/download/")
  url <- configuration$url
  response <- call_or_refresh(function()
  {
    return(httr::GET(url=paste0(url, suburl), config=build_header(configuration$token)))
  })
  if (response$status_code != 200)
  {
    stop(paste0('download_table failed with error code ', response$status_code, ". you can manually download the table by visiting ", paste0(url, suburl)))
  }
  cat('success/n')
  return(httr::content(response))
}

#'
#'
#' @export
create_item <- function(item, tablename)
{
  suburl <- paste0("/data/", tablename, "/")
  url <- configuration$url
  response <- call_or_refresh(function()
  {
    return(httr::POST(url=paste0(url, suburl), body=item, config=build_header(configuration$token)))
  })
  if (response$status_code != 201)
  {
    stop(paste0('create_item failed with error code ', response$status_code))
  }
  cat('success/n')
  return(httr::content(response))
}

#'
#'
#' @export
edit_item <- function(uuid, item, tablename)
{
  suburl <- paste0("/data/", tablename, "/", uuid, "/")
  url <- configuration$url
  response <- call_or_refresh(function()
  {
    return(httr::PATCH(url=paste0(url, suburl), body=item, config=build_header(configuration$token)))
  })
  if (response$status_code != 200)
  {
    stop(paste0('edit_item failed with error code ', response$status_code))
  }
  cat('success/n')
  return(httr::content(response))
}
