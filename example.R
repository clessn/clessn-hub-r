devtools::install_github("clessn/clessn-hub-r")
# https://github.com/clessn/quorum-api/issues/126

# ------------------------------
# Configure the connection
clessnhub::configure()
clessnhub::configure("http://localhost:8000")
# or (NEVER PUT THIS ON GITHUB)
clessnhub::login('myusername', '******')


# Get a list of all table names
tablenames <- clessnhub::fetch_tablenames()


# Download a table into a tibble
charts <- clessnhub::download_table('quorum_charts')


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

