devtools::install_github("clessn/clessn-hub-r")
# https://github.com/clessn/quorum-api/issues/126

# ------------------------------
# se connecter au hub 2.0
clessnhub::connect()
clessnhub::connect_with_token("6d9dec6a9361145ac6eec9e8ce7642852c3942cb")


# test
a <- clessnhub::create_item("agoraplus_interventions", key="test", type="test", schema="v1", metadata = list(potato="tomato"), data = list(banana="apple"))

clessnhub::edit_item('agoraplus_interventions', key="test", type="test", schema="v1", metadata = list(potato="radish"), data = list(banana="pear"))

clessnhub::delete_item("agoraplus_interventions", key="test")





# Radarplus
clessnhub::connect()
f <- clessnhub::create_filter(uuid="a9368e68-a2e3-4f82-b12c-b738582b2775")
item <- clessnhub::get_items("agoraplus_interventions")

filter <- clessnhub::create_filter(metadata=list(date__gt="2021-06-01"))
filter <- clessnhub::create_filter(metadata=list(source="tva-nouvelles",date__gt="2021-03-01T00:00:00"))
data <- clessnhub::get_items("radarplus_articles", filter, download_data=T)

filter <- clessnhub::create_filter(metadata=list(date__gt="2019-01-01"))
data <- clessnhub::get_items("persons", filter, download_data=T)


# ou (dans la console seulement, ne pas pousser son identifiant sur github)
clessnhub::login('myusername', '******')

# lister toutes les tables disponibles
tablenames <- clessnhub::list_tables()

# créer un filtre
key_filter <- clessnhub::create_filter(key="mykey")
other_filter <- clessnhub::create_filter(type="MemberParliament", schema = "v1")

jsondata_filter <- clessnhub::create_filter(data=list(eventID="alpha", interventionID="bravo"))
# Matcherait cette structure
# {
#   "eventID": "alpha",
#   "interventionID": "bravo"
# }
#

# filtrer pat date (YYYY-MM-DD)
between_dates_filter = clessnhub::create_filter(date_after = "1992-01-01", date_before = "1995-01-01")


# récupérer un éléement
journalist_filter <- clessnhub::create_filter(data=list(gender="female", source="radio-canada"))
journalists <- clessnhub::get_items("persons", download_data = F)

jeanpierre_filter <- clessnhub::create_filter(metadata = list(verifie_par="Jean-Pierre"))
clessnhub::create_filter(type="radio-canada", data=list(author="Louis Blouin"))

# créer un nouvel élément
bob <- clessnhub::create_item("persons", "bob", "Journalist", "v1", "1990-04-30", list(tags=list(coffee="", tea="")), list(gender="male", source="radio-canada"))
gina <- clessnhub::create_item("persons", "gina", "Journalist", "v1", "1993-01-20", list(tags=list(coffee="", tea="")), list(gender="male", source="radio-canada"))

gina_result <- clessnhub::get_items("persons", between_dates_filter)

# est-ce que l'élément existe?
bob_filter <- clessnhub::create_filter(metadata=list(tags__tea=""))
bob <- clessnhub::get_items("persons", bob_filter)
bob_exists <- !is.null(clessnhub::get_items("persons", bob_filter, download_data = F))
print(bob_exists)

# modifier un élément
clessnhub::edit_item("persons", "bob", type="Politician")

# supprimer un élément
clessnhub::delete_item("persons", "bob")
clessnhub::delete_item("persons", "gina")

#
#
# Accès aux banques de données
#
#

# se connecter au hub 2.0
clessnhub::connect()

# Voir la liste des banques de données accessibles
clessnhub::list_databanks()

# Voir la liste des permissions que nous avons sur une banque
clessnhub::list_databank_permissions("quorum_respondents")

# télécharger les données d'une banque
data <- clessnhub::get_databank_items("quorum_respondents", filter=list(days=2))

# quorum_respondents filters
user_id = list(user_id="c70e08c8-b779-445e-a58f-984000847537")
last_30_days = list(days=30)
prod_only = list(origin="prod")
engineers_only = list(profile_data__selected_profile="engineer")
french_only = list(answer_data__ses_lang__answer_value="french")

data <- clessnhub::get_databank_items("quorum_respondents", filter=list(days=19))


# soummetre un log ou Voir les logs
clessnhub::log("radarplus", "some data", "some metadata")

logs <- clessnhub::get_items("logs", list(app="radarplus", date="2021-05-31"))



library(dplyr)
# configure and download
clessnhub::v1_configure()
data <- clessnhub::v1_download_table("agoraplus_warehouse_intervention_items")

# validate no duplicate in raw data
TRUE %in% duplicated(data$uuid)

# create slug
dfDeep.hub <- select(data, uuid, eventID, interventionSeqNum, speakerIsMinister, speakerType, speakerParty,
         speakerCirconscription, speakerSpeechLang, speakerSpeech,
         speakerFirstName, speakerLastName, speakerFullName) %>%
  mutate(slug = paste0(eventID, interventionSeqNum))

# validate no duplicate slug, THERE ARE DUPLICATES
TRUE %in% duplicated(dfDeep.hub$slug)

# Generate frequencies for each slug
n_occur <- data.frame(table(dfDeep.hub$slug))
n_occur <- n_occur[n_occur$Freq > 1,]

# Find items that occur more than once
guilty_elements <- dfDeep.hub[dfDeep.hub$slug %in% n_occur$Var1,]

a <- guilty_elements[duplicated(guilty_elements$slug),]
for (i in 1:nrow(a))
{
  tryCatch(
    {
      print(a$uuid[i])
      clessnhub::v1_delete_item(a$uuid[i], "agoraplus_warehouse_intervention_items")
      print(i)
    },
    error=function(cond)
    {
      print(paste("error at", i))
      return(NA)
    }
  )

}

