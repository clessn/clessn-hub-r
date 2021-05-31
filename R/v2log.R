#'
#' @export
log <- function(app, data, metadata)
{
  path <- "/data/entry/"
  response <- http_post(path, list(app=app, data=data, metadata=metadata))
  if (response$status_code != 200)
  {
    warning(paste("Pas réussi à logger, erreur", response$status_code))
  }
  else
  {
    cat(paste(app, data, "\n"))
  }
}
