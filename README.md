## GoogleLocationHistory
R package to download and parse Google location history

### Example Usage
    devtools::install_github("corynissen/GoogleLocationHistory")
    library("GoogleLocationHistory")

    username <- "corynissen@gmail.com"  
    password <- "mygooglepassword"

    sess <- login(username=username, password=password)
    df <- location_history(session=sess, date="2016-04-04")
    kml <- location_history(session=sess, date="2016-04-04", asKML=TRUE)
    
    # remove duplicate points for faster plotting
    df2 <- df[!duplicated(df$lat, df$lon), ]
    df2 <- df2[order(df2$time), ] 

    library(ggmap)
    maptile <- get_map(location=c(lon=((max(df2$lon) + min(df2$lon)) / 2),
                                  lat=((max(df2$lat) + min(df2$lat)) / 2)))
    mymap <- ggmap(maptile)
    for(i in seq_along(1:nrow(df2))){
      mymap <- mymap + geom_point(x=df2$lon[i], y=df2$lat[i])
    }
    mymap

    library("leaflet")
    map <- leaflet() %>% addTiles()
    for(i in 1:nrow(df2)){
      map <- map %>% addMarkers(lat=df2$lat[i], lng=df2$lon[i])
    }
    map

    map <- leaflet() %>% addTiles()
    for(i in 2:nrow(df2)){
      map <- map %>% addPolylines(lat=df2$lat[(i-1):i], lng=df2$lon[(i-1):i])
    }
    map
