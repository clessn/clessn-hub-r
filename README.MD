# CLESSN Hub R package

## Documentation
install with `devtools::install_gihhub("clessn/clessn-hub-r")`

*How to Login*
`clessnhub::configure()`
1. Enter your username in the terminal
2. Enter your password in the popup window

This creates a config object in your global environment and contains some security information. This object is used automatically by other functions of the package.

*Download ALL the data from a table*
`data <- clessnhub::download('my-table-name')`
The data object stores the date at which it was downloaded, so when you refresh the data, it'll refresh from the last download date.

*Refresh your data*
`data <- clessnhub::refresh(data)`
This will download all data created or modified since the last time refresh or download was called on the data object.
*IMPORTANT*: There's no way to know if a row has been deleted.This means that if a row is deleted on the server, it will not disappear from your data object until you re-download all of the data.

*Upload an object*
`clessnhub::upload('my-table-name', list(<containing minimum needed data>))`
You can always visit [https://clessn.apps.valeria.science/data/](https://clessn.apps.valeria.science/data/) to know what data is needed.

*Delete an item*
`clessnhub::delete('my-table-name', '<uuid>')`
