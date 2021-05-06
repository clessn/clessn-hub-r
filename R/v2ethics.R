list_databanks <- function()
{
  response <- http_get("/ethics/", verify=F)
  if (response$status_code >= 400)
  {
    stop("Une erreur s'est produite ou vous n'êtes plus connecté. Connectez-vous de nouveau.")
  }
  return(names(httr::content(response)))
}

list_databank_permissions <- function(databank)
{
  # somehow fetch the user's permissions for the current databank
}

list_databank_filters <- function(databank)
{
  # somehow list all possible filter parameters for the given table
}

get_databank_items <- function(databank, filters=list())
{
  filter$format <- "json"

  message("Téléchargement en cours...")
  response <- http_get(paste0("/ethics/", databank, "/"), options=filter, verify=F)
  if (response$status_code == 403)
  {
    stop("Une erreur s'est produite. Vous n'avez pas accès à cette resource.")
  }
  if (response$status_code == 404)
  {
    stop("La table que vous tentez de lire n'existe pas.")
  }

  if (response$status_code != 200)
  {
    warning(paste("Erreur",response$status_code))
  }

  filter$format <- "csv"

  data <- dplyr::tibble()
  code <- response$status_code
  count <- httr::content(response)$count
  page <- 1
  if(count == 0)
  {
    message("0 éléments")
    return(NULL)
  }

  repeat {
    filter$page <- page
    response <- http_get(paste0("/ethics/", table, "/"), options=filter, verify=F)
    code <- response$status_code
    if (code != 200)
    {
      cat("\n")
      break
    }
    else
    {
      downloaded_data <- suppressMessages(httr::content(response))
      data <- dplyr::bind_rows(data, downloaded_data)
      page <- page + 1
      cat("\r", paste0(nrow(data), "/", count))
    }
  }
  message("...Téléchargement complété!")
  return(data)
}
