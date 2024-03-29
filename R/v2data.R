#'
#' @export
list_tables <- function()
{
  response <- http_get("/data/")
  if (response$status_code >= 400)
  {
    stop("Une erreur s'est produite ou vous n'êtes plus connecté. Connectez-vous de nouveau.")
  }
  return(names(httr::content(response)))

}

#'
#' @export
create_filter <- function(key_contains=NULL, key=NULL, uuid=NULL, type=NULL, type_contains=NULL, schema=NULL, schema_contains=NULL, metadata=list(), data=list())
{
  filter <- list()
  if (!is.null(key_contains))
    filter$key_contains <- key_contains

  if (!is.null(key))
    filter$key <- key

  if (!is.null(uuid))
    filter$uuid <- uuid

  if (!is.null(type))
    filter$type <- type

  if (!is.null(type_contains))
    filter$type_contains <- type_contains

  if (!is.null(schema))
    filter$schema <- schema

  if (!is.null(schema_contains))
    filter$schema_contains <- schema_contains

  if (length(data) > 0)
    filter$data <- paste(names(data), data, sep=":", collapse=',')

  if (length(metadata) > 0)
    filter$metadata <- paste(names(metadata), sep=":", metadata, collapse=',')
  return(filter)
}


#'
#' @export
get_items <- function(table, filter=list(page=1), download_data=TRUE, max_pages=-1)
{

  filter$format <- "json"

  message("Téléchargement en cours...")
  response <- http_get(paste0("/data/", table, "/"), options=filter)
  if (response$status_code == 401)
  {
    stop("Il y a sans doute une erreur de connection. Connectez-vous de nouveau.")
  }
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

  if (download_data)
    filter$get_data <- "true"

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
    response <- http_get(paste0("/data/", table, "/"), options=filter)
    code <- response$status_code
    if (code == 404)
    {
      cat("\n")
      break
    }
    else if (code != 200)
    {
      warning(paste("Erreur",code))
    }
    else
    {
      downloaded_data <- suppressMessages(httr::content(response))
      data <- dplyr::bind_rows(data, dplyr::mutate_all(downloaded_data, as.character))
      page <- page + 1
      cat("\r", paste0(nrow(data), "/", count))

      if (max_pages > 0 && page > max_pages)
      {
        break
      }
    }
  }
  message("...Téléchargement complété!")
  return(data)
}


#'
#' @export
get_item <- function(table, key)
{
  message("téléchargement d'un élément...")
  response <- http_get(paste0("/data/", table, "/", key, "/?format=json&get_data=true"))
  if (response$status_code == 400)
  {
    stop("400: Les données sont mal formées.")
  }

  if (response$status_code == 403)
  {
    stop("403: Vous n'avez sans doute pas le droit de voir cet élément")
  }

  if (response$status_code == 200)
  {
    message("élément téléchargé")
    return(httr::content(response))
  }
  else
  {
    stop(response$status_code)
  }
}


#'
#' @export
create_item <- function(table, key, type, schema, metadata, data)
{
  message("ajout d'un élément...")
  metadata <- jsonlite::toJSON(metadata, auto_unbox = T)
  data <- jsonlite::toJSON(data, auto_unbox = T)
  response <- http_post(paste0("/data/", table, "/"), body=list(key=key, type=type, schema=schema, metadata=metadata, data=data))
  if (response$status_code == 400)
  {
    stop("400: L'élément existe déjà ou les données sont mal formées.")
  }

  if (response$status_code == 403)
  {
    stop("403: Vous n'avez sans doute pas le droit de créer un nouvel élément.")
  }

  if (response$status_code == 201)
  {
    message("élément ajouté")
    return(httr::content(response))
  }
  else
  {
    stop(response$status_code)
  }
}

#'
#' @export
edit_item <- function(table, key, type=NULL, schema=NULL, metadata=NULL, data=NULL)
{
  message("modification d'un élément...")
  body = list()

  if (!is.null(type))
    body$type = type

  if (!is.null(schema))
    body$schema = schema

  if (!is.null(metadata))
    body$metadata = jsonlite::toJSON(metadata, auto_unbox = T)

  if (!is.null(data))
    body$data <- jsonlite::toJSON(data, auto_unbox = T)

  response <- clessnhub::http_update(paste0("/data/", table, "/", key, "/?format=json&get_data=true"), body)
  if (response$status_code == 400)
  {
    stop("400: les données de l'item sont mal formées.")
  }
  if (response$status_code == 404)
  {
    stop("404: l'item à modifier ne semble pas exister.")
  }

  if (response$status_code == 403)
  {
    stop("403: Vous n'avez sans doute pas le droit de modifier cet élément.")
  }

  if (response$status_code == 200)
  {
    message("élément modifié")
  }
  else
  {
    stop(response$status_code)
  }
}

#'
#' @export
delete_item <- function(table, key)
{
  message("suppression d'un élément...")
  response <- clessnhub::http_delete(paste0("/data/", table, "/", key))
  if (response$status_code == 400)
  {
    stop("400: les données de l'item sont mal formées.")
  }
  if (response$status_code == 404)
  {
    stop("404: l'item à supprimer ne semble pas exister.")
  }

  if (response$status_code == 403)
  {
    stop("403: Vous n'avez sans doute pas le droit de supprimer un élément.")
  }

  if (response$status_code == 204)
  {
    message("élément supprimé")
  }
  else
  {
    stop(response$status_code)
  }
}
