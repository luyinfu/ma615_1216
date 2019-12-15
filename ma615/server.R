
library(shiny)

shinyServer(function(input, output) {

    output$map <- renderLeaflet({
        
        filmname <- reactive({
            filter(film_loc, Title == input$filmname)
        })
        observeEvent(filmname(), {
            choices <- unique(filmname()$Locations)
            updateSelectInput(session, "location", choices = choices) 
        })
        
        
        
        
        
        # create San Francisco Map
        leaflet() %>% #set the coordinates for San Francisco
            setView(-122.4194, 37.7749, zoom = 12) %>% 
            addProviderTiles("CartoDB.Positron", group = "Map") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellite")%>% 
            addProviderTiles("OpenStreetMap", group = "Mapnik")
    })
    output$FunFacts <- renderText({
        funfacts1=funfacts %>% filter(Title==input$filmname, Locations==input$location)
        if (funfacts1$Fun.Facts==""){
            paste("Oops! Fun fact not recorded")
        }else{
            paste(funfacts1$Fun.Facts)
        }
    })
    output$wordcloud <- renderPlot({
        pal2 <- brewer.pal(8,"Dark2")
        set.seed(8)
        tibble(description) %>% 
            unnest_tokens(word, description) %>%
            anti_join(stop_words) %>%
            count(word, sort = TRUE) %>%
            with(wordcloud(word, n, max.words = 100, rot.per = 0.25, colors = pal2, random.order=FALSE, vfont=c("serif","plain"))) 
    })

})
