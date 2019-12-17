
library(shiny)


shinyServer(function(input, output, session) {
    
    filmname <- reactive({
        filter(funfacts, Title == input$filmname)
    })
    observeEvent(filmname(), {
        choices <- unique(filmname()$Locations)
        updateSelectInput(session, "location", choices = choices) 
    })

    output$map <- renderLeaflet({
        film_loc1=film_loc %>% drop_na(lon) %>% filter(Title==input$filmname)
        #define icons for film shooting spots 
        icons1 <- awesomeIcons(
            icon = 'home',
            iconColor = 'rgba',
            library = 'fa', 
            markerColor = 'lightblue',
            squareMarker = F,
            spin=T
        )
        # create San Francisco Map
        leaflet(film_loc1) %>% #set the coordinates for San Francisco
            setView(-122.4194, 37.7749, zoom = 12) %>% 
            addProviderTiles("CartoDB.Positron", group = "Map") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellite")%>% 
            addProviderTiles("OpenStreetMap", group = "Mapnik") %>% 
            #add markers for the locations where the selected film was shot
            addAwesomeMarkers(~lon, ~lat, label = ~Locations, icon = icons1) %>%
            addScaleBar(position = "bottomleft") 
            
    })
    output$FunFacts <- renderText({
        #Fun fact form the dataset
        funfacts1=funfacts %>% filter(Title==input$filmname, Locations==input$location) %>%
            distinct()
        paste(as.character(funfacts1$Fun.Facts[1]))
    })
    #output for plot1, a barchart that shows the number of films shot in SF each year by specified Production Company
    output$plot1 <- renderPlotly({
        pc_row=film_loc %>% filter(Title==input$filmname)
        p1=film_loc %>% filter(`Production Company`==pc_row[1,13]) %>% 
            select(`Production Company`, Release.Year, Title) %>%
            distinct() %>%
            mutate(n=n()) %>%
            ggplot() + aes(x=as.character(Release.Year), y=n)+ 
            geom_bar(stat = "identity", fill="#5F9EA0") +
            labs(x = "year",
                 y = "films shot in SF",
                 title=paste(pc_row[1,13])
                 )
        ggplotly(p1)
    })
    output$wordcloud <- renderPlot({
        pal2 <- brewer.pal(8,"Dark2")
        set.seed(8)
        tibble(description) %>% 
            unnest_tokens(word, description) %>%
            anti_join(stop_words) %>%
            count(word, sort = TRUE)
        wordfreq=tibble(description) %>% 
            unnest_tokens(word, description) %>%
            anti_join(stop_words) %>%
            count(word, sort = TRUE)
        wordcloud(wordfreq$word, freq = wordfreq$n, scale=c(6, 0.7), 
                  max.words = 100, rot.per = 0.25, colors = pal2, random.order=FALSE, 
                  vfont=c("serif","plain")) 
    })
    output$news <- renderTable({
        news=get_everything(query = paste("san francisco", input$category), sort_by = "relevancy", page = 1, 
                            page_size = 100, api_key ="6572647b5bd941efa75620ffe1bfeca0")
        news$results_df[c(2,3,1,4)]
    })

})
