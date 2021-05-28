devtools::install_github("clessn/clessn-hub-r")
# https://github.com/clessn/quorum-api/issues/126

# ------------------------------
# se connecter au hub 2.0
clessnhub::connect()

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
between_dates_filter = clessnhub::create_filter()


# récupérer un éléement
journalist_filter <- clessnhub::create_filter(data=list(gender="female", source="radio-canada"))
journalists <- clessnhub::get_items("persons", download_data = F)

jeanpierre_filter <- clessnhub::create_filter(metadata = list(verifie_par="Jean-Pierre"))

# créer un nouvel élément
nouveau_journaliste <- clessnhub::create_item("persons", "bob", "Journalist", "v1", "1990-04-30", list(tags=list(coffee="", tea="")), list(gender="male", source="radio-canada"))

# est-ce que l'élément existe?
bob_filter <- clessnhub::create_filter(metadata=list(tags__tea=""))
bob <- clessnhub::get_items("persons", bob_filter)
bob_exists <- !is.null(clessnhub::get_items("persons", bob_filter, download_data = F))
print(bob_exists)

# modifier un élément
clessnhub::edit_item("persons", "bob", type="Politician")

# supprimer un élément
clessnhub::delete_item("persons", "bob")

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


