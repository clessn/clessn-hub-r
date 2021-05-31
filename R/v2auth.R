#'
#' @export
login <- function(username, password, url="https://clessnhub.apps.valeria.science")
{
  message(paste0("connexion à ", url, " en cours..."))
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  response <- httr::POST(url=paste0(url, '/api-token-auth/'), body = list(username=username, password=password), verify=F)

  if (response$status_code >= 500)
  {
    stop("Une erreur s'est produite. Contactez un administrateur")
  }

  if (response$status_code >= 400)
  {
    stop("Une erreur s'est produite. Assurez-vous que vos informations de connexion sont bonnes")
  }

  token <- httr::content(response)$token
  hub_config <<- list(token=token, url=url, token_prefix="Bearer")
  message("...connexion réussie!")
}

#'
#' @export
connect <- function(url="https://clessnhub.apps.valeria.science")
{
  username <- getPass::getPass("Nom d'utilisateur: ")
  password <- getPass::getPass("Mot de passe: ")
  login(username, password, url)
}
