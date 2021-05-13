
#' return whether the specified uuid is in tablename
#'
#' @export
v1_item_exists <- function(uuid, tablename)
{
  warning("cette fonction sera bientôt retirée.")
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
v1_delete_item <- function(uuid, tablename)
{
  warning("cette fonction sera bientôt retirée.")
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
    cat('success')
  }
  else
  {
    stop(paste0('delete_item failed with error code ', response$status_code))
  }
}

#' return the specified uuid from tablename
#'
#' @export
v1_get_item <- function(uuid, tablename)
{
  warning("cette fonction sera bientôt retirée.")
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
  cat('success')
  return(httr::content(response))
}

#' Download data through the API, one page at a time. Easy on the server,
#' heavy on the client.
#'
#' @export
v1_download_light <- function(tablename, stringsAsFactors=FALSE)
{
  warning("cette fonction sera bientôt retirée.")

  suburl <- paste0("/data/", tablename)
  url <- configuration$url
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  page <- 1
  count <- 0
  data <- list()

  response <- call_or_refresh(function()
  {
    return(httr::GET(
      url=paste0(url, suburl, "/?page=", page),
      config=build_header(configuration$token),
      httr::add_headers(Accept='*/*')))
  })

  while (TRUE)
  {
    response <- httr::GET(
      url=paste0(url, suburl, "/?page=", page),
      config=build_header(configuration$token),
      httr::add_headers(Accept='*/*'))
    if (response$status_code != 200)
    {
      if (response$status_code == 403)
      {
        stop("Error while downloading. Try logging in again through configure()")
      }
      stop(paste0('download_table failed with error code ', response$status_code))
    }
    else
    {
      content = httr::content(response)
      count <- content$count
      items <- content$results

      data <- c(data, items)
      cat("\r", paste0(length(data), "/", count))

      if (!is.null(content[["next"]]))
      {
        page <- page + 1
      }
      else
      {
        cat("success")
        return(data.table::rbindlist(data))
      }
    }
  }
}

#' Download data as csv, where the server generates the csv. Heavy on the
#' server, easy on the client.
#'
#' @export
v1_download_table <- function(tablename, stringsAsFactors=FALSE)
{
  warning("cette fonction sera bientôt retirée.")
  suburl <- paste0("/data/", tablename, "/download/")
  url <- configuration$url
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  response <- call_or_refresh(function()
  {
    tryCatch({
        httr::GET(
          url=paste0(url, suburl),
          config=build_header(configuration$token),
          httr::add_headers(Accept='*/*'),
          httr::write_disk('table.csv', overwrite=TRUE),
          httr::progress())
    },
    error=function(cond)
    {
      if (grepl("receiving data from the peer", cond, fixed=T))
      {
        return(NA)
      }
      stop(cond)
    })
  })
  if ((is.atomic(response) && is.na(response)) || response$status_code == 200)
  {
    cat('success')
    data <- read.csv('table.csv', stringsAsFactors=stringsAsFactors)
    file.remove('table.csv')
    return(data)
  }
  stop(paste0('download_csv failed with error code ', response$status_code))

}

#'
#'
#' @export
v1_create_item <- function(item, tablename)
{
  warning("cette fonction sera bientôt retirée.")
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
  cat('success')
  return(httr::content(response))
}

#'
#'
#' @export
v1_edit_item <- function(uuid, item, tablename)
{
  warning("cette fonction sera bientôt retirée.")
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
  cat('success')
  return(httr::content(response))
}
