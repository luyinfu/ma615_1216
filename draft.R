film=read.csv("Film_Locations_in_San_Francisco.csv")
devtools::install_github("dkahle/ggmap")
library(ggmap)

register_google(key = "AIzaSyBFs5oqwXv3ovQaKNbSqCLIe9sqAcpjvNo")

lonlat <- geocode(paste(as.character(film$Locations), " SF"))
film_loc=cbind(film, lonlat)
write.csv(film_loc, "film_loc.csv", row.names = FALSE)





library(maps)
library(leaflet)
bounds <- map('state', 'California', fill=TRUE, plot=FALSE)
leaflet() %>% 
  setView(-122.4194, 37.7749, zoom = 12) %>% 
  addProviderTiles("CartoDB.Positron", group = "Map") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite")%>% 
  addProviderTiles("OpenStreetMap", group = "Mapnik")


df1 <- get_headlines(query = "san francisco", category = terms_category[[1]][1], page = 1, page_size = 100, api_key ="6572647b5bd941efa75620ffe1bfeca0")
df1$results_df[[3]]



