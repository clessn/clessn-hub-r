# CLESSN Hub R package (v2)

## Concepts

La version 2 du package clessnhub, qui fonctionne de pair avec la v2 du hub sur VALERIA, ajoute et modifie quelques concepts sur la façon d'accéder aux données.

Il y a trois grandes sections au hub:
* Le data (les tables)
* les banques de données (les databanks)
* les fichiers (files and tags)

### Tables
Une table représente un série de données similaire à un dataframe. Les données d'une table sont accessible à tous ceux qui possèdent un compte sur le hub (pourrait changer). Les tables servent à stocker des données de recherche non-sensible pour le partage et l'accès par des systèmes automatisés.

La fonction R `clessnhub::list_tables()` retourne une liste de toutes les tables existantes.

#### Champs
Le format de chaque table est indentique jusqu'à un certain point. On y retrouve les champs suivant:
* `key`: La clé unique qui différencie chaque élément d'une même table
* `type`: Le type de l'élément. Ce champ a pour but d'aider a différencier différents types d'éléments d'une même table. ie. Supposant une table de personnes, le type pourrait prendre comme valeur "journalist" ou "minister", afin de faciliter le filtrage
* `data`: Ce champ spécial au format JSON permet de stocker toute sorte d'information selon la structure qui nous convient. Bien qu'il soit libre aux chercheurs de stocker de l'information comme bon leur semble, il est recommandé de respecter une structure déterminée afin de faciliter le partage
* `schema`: ce champ sert d'indicateur de la structure et le format du champ data.

Supposons une table de personnes qui contient l'élément suivant:
`key`: `francois_legault`
`type`: `politician`
`schema`: `v1`
`data`:
```json
{
    "first_name": "François",
    "last_name": "Legault",
    "post": "Premier",
    "province": "Quebec"
}
```
Nous supposons que les chercheurs qui travaillent sur la table `Personnes` se sont entendues pour respecter quelques règles:
* Ils s'entendent pour que la clé d'une personne soit toujours son prénom et son nom de famille avec underscore plutôt qu'espace
* Ils s'entendent pour que le type soit toujours un de `politician` ou `journalist`
* Ils s'entendent que le schéma v1 soit toujours au format montré ci-haut, soit 4 champs `first_name`, `last_name`, `post` et `province`

Notez que chaque élément possède aussi un identifiant unique universel (uuid). Celui-ci ne peut être modifié sur un élément existant et agit simplement comme alternative à la clé unique. Dans la majorité des cas, vous ne l'utiliserez pas.

Quelques semaines plus tard, les chercheurs s'apperçoivent qu'ils aimeraient organiser l'information différemment. On préférerait une structure au format suivant:
```json
{
    "name": {
        "first_name": "François",
        "last_name": "Legault",
        "full_name": "François Legault"
    },
    "location": "quebec",
    "role": {
        "post": "Premier",
        "parliament": "quebec",
        "since": "2018"
    },
    "metadata": {
        "added_by": "Chercheur A",
        "added_on": "29-04-2021"
    }
}
```
Comme vous voyez, la structure est bien différente et contient beaucoup plus d'information. Ça veut aussi dire qu'elle n'est plus vraiment compatible avec l'ancienne, et donc qu'il faudrait convertir toutes les personnes de la table au nouveau format, ce qui peut être lourd et complexe. Alternativement, on peut définir cette nouvelles structure, ce nouveau schéma, comme le schéma v2. Ceci nous permet de savoir, rapidement, quelle entrée contient quelle information, et ce qui reste à convertir. À long terme, cela nous permet d'emmagasiner beaucoup d'information sans trop avoir à se soucier de la structure des données plus vieilles, à condition que la structure des schémas soit respectée.


#### Filtres et téléchargement
Pour télécharger toutes les données d'une table, on utilise la fonction `clessnhub::get_items("nom_de_la_table")`. Cette fonction retournera un tibble contenant toutes les données dans un format applati plutôt qu'en arbre. Dans l'exemple plus haut, le tibble aurait des colonnes comme `key`, `type` mais aussi `data.name.first_name` et `data.role.post`.

Parfois, une table possède beaucoup de données et toute les télécharger n'est pas une option viable. On peut alors créer un filtre. la fonction `clessnhub::create_filter` contient les filtres possible. Notez que certains de ces filtres pourraient ne retourner qu'une seule valeur, et la combinaison des filtres s'applique de manière mutuelle; on récupère les éléments qui sont compatible avec valeurA ET valeurB, pas valeurA OU valeurB. 

Voici quelques exemples de création de filtre.
`clessnhub::create_filter(key="francois_legault")` nous retournera un tibble d'un seul élément dont la clé est `francois_legault` si bien sur cet élément est présent.

`clessnhub::create_filter(type="politician", schema = "v1")` nous retournera tous les politiciens dont le schéma est `v1`.

`clessnhub::create_filter(data=list(role__post="Premier", name__last_name="Legault"))` nous permet de filtrer dans les champs contenu dans `data`. Le double underscore nous permet de naviguer à travers un champ et est similaire au point `.` qu'on trouverait dans le nom des colonnes du tibble.

Pour télécharger nos données, on applique le filtre à la fonction de téléchargement:
```R
mon_filtre <- clessnhub::create_filter(key="francois_legault")
clessnhub::get_items("personnes", mon_filtre)
```

Notez qu'un filtre qui retournerait zéro élément retournera en fait la valeur NULL. On peut donc valider si un élément existe avec `is.null`.
```R
mon_filtre <- clessnhub::create_filter(key="francois_legault")
legault <- clessnhub::get_items("personnes", mon_filtre)
if (is.null(legault))
  print("Legault n'existe pas!")
```


#### Ajout, modification et suppression

À venir

### Banques de données
#### Accès et permissions
#### Champs
#### Filtres et téléchargement

## Documentation
### Installation
`devtools::install_gihhub("clessn/clessn-hub-r")`
### Fonctions

## Exemples
```
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

