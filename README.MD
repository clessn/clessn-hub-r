# CLESSN Hub R package

## Documentation
install with `devtools::install_gihhub("clessn/clessn-hub-r")`

## Usage
```
# Configure the connection
clessnhub::configure()
# or (NEVER PUT THIS ON GITHUB)
clessnhub::login('myusername', '******')


# Get a list of all table names
tablenames <- clessnhub::fetch_tablenames()


# Download a table into a tibble
charts <- clessnhub::download_table('quorum_answers')


# Return an empty tibble of a table with all columns
# NOT IMPLEMENTED YET
table_schema <- clessnhub::fetch_tableschema('quorum_answers')


# Returns TRUE if an item with the specified uuid exists
clessnhub::item_exists('095c1582-4301-4cbc-a8e6-d5e8f58a44fa', 'quorum_answers')


# Get ONE specific element from a table in named list format
item <- clessnhub::get_item('095c1582-4301-4cbc-a8e6-d5e8f58a44fa', 'quorum_answers')


## Delete an item from the table
clessnhub::delete_item('80af0dd9-dc8b-4881-bccd-d9e570738675', 'quorum_answers')


# Create a new item in a table, then return it in list format
newitem <- clessnhub::create_item(item, 'quorum_answers')


# Edit an existing item in a table, return the new item in list format
clessnhub::edit_item(newitem$uuid, item, 'quorum_answers')
```

## Use cases
Change the type of a potato "lovely-potato" in the table my-potatoes
```
# login
clessnhub::configure()

# download the table
potato_table <- clessnhub::download_table('my-potatoes')

# find the potato named 'lovely-potato' and convert it as a list
lovely_potato <- as.list(potato_table[which(potato_table$name == 'lovely-potato'), ])

# modify the potato's type
lovely_potato$type = 'King Potato'

# reupload the potato using its uuid
clessnhub::edit_item(lovely_potato$uuid, lovely_potato, 'my-potatoes)
```
