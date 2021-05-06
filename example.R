devtools::install_github("clessn/clessn-hub-r")
# https://github.com/clessn/quorum-api/issues/126

# ------------------------------
# se connecter au hub 2.0
clessnhub::connect(url="localhost:8080")

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
