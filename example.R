devtools::install_gihhub("clessn/clessn-hub-r")
# https://github.com/clessn/quorum-api/issues/126

# ------------------------------
# Configure the connection
clessnhub::configure()

# Download the current data
table_name <- 'quorum_charts'
charts <- clessnhub::download(table_name)

chart_id <- charts$df[which(charts$df$chart_name == "quorum-chart-radarplus"), ]$uuid

new_data <- list(points = '[1, 2, 3, 4]')
clessnhub::update(table_name, chart_id, new_data)



# ------------------------------
#data <- clessnhub::refresh(data)
#clessnhub::refresh_token()
#clessnhub::delete(table, 'b063902e-f866-46ac-a303-5d03c4216692')


