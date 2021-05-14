# CLESSN Hub R package (v2)

## Concepts
Il existe deux sortes de tables:
* les tables de données (data), pour les données non-sensibles
* les banques de données (ethics), pour les données sensibles

les banques de données ne sont accessibles que par les personnes autorisées et possèdent chacunes leur structure unique.
Les tables, elles, ont toutes une structure générale similaire:
* key: une clé unique afin de permettre d'identifier les éléments (francois_legault01)
* type: le type de la données, permet de classifier différents types dans une même table (ex. Journaliste vs Député vs Ministre)
* metadata: De l'information sur la donnée, optionnel, au format JSON (ex: created_by, last_modified)
* data: Les données, au format JSON (ex: first_name, last_name, source, party)
* schema: un identifiant qui indique la structure des données et des métadonnées (ex: v1, journalist_v1)

Note: Malgré la mention de JSON, les données téléchargées sont applaties en un tibble. Ce n'est que lors de la modification ou la création de données que le JSON est nécessaire. Le package jsonlite est particulièrement pertinent.


## Support v1
Il est encore possible d'accéder au ancien hub, mais le nom des fonctions a changé.
ie: v1_configure, v1_login, v1_download_table, v1_download_light, etc.

## Exemples
```r
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
uuid_filter <- clessnhub::create_filter(uuid="2a16f388-a3c7-4e12-8190-dd42f1c247ea")
other_filter <- clessnhub::create_filter(type="MemberParliament", schema = "v1")

jsondata_filter <- clessnhub::create_filter(data=list(potato="tomato", objects__banana="fun"))
# Matcherait cette structure
# {
#   "potato": "tomato",
#   "objects": {"banana": "fun"}
# }
#

# récupérer un éléement
journalist_filter <- clessnhub::create_filter(data=list(gender="female", source="radio-canada"))
journalists <- clessnhub::get_items("warehouse_journalists", journalist_filter)

# créer un nouvel élément
nouveau_journaliste <- clessnhub::create_item("warehouse_journalists", "bob", "Journalist", "v1", list(gender="male", source="radio-canada"))

# est-ce que l'élément existe?
bob_filter <- clessnhub::create_filter(key="bob")
clessnhub::get_items("warehouse_journalists", bob_filter)
bob_exists <- !is.null(clessnhub::get_items("warehouse_journalists", bob_filter))
print(bob_exists)

# supprimer un élément
clessnhub::delete_item("warehouse_journalists", "bob")

```

### Accéder à une banque de données
```r
# se connecter au hub 2.0
clessnhub::connect()

# Voir la liste des banques de données accessibles
clessnhub::list_databanks()

# Voir la liste des permissions que nous avons sur une banque
clessnhub::list_databank_permissions("quorum_respondents")

# télécharger les données d'une banque
data <- clessnhub::get_databank_items("quorum_respondents", filters=list(days=2))
```
