library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(magrittr)

film_loc=read.csv("film_loc.csv")

funfacts=film_loc %>% select(Title, Locations, Fun.Facts) 

df <- get_everything(query = "san francisco", sort_by = "relevancy", page = 1, page_size = 100, api_key ="6572647b5bd941efa75620ffe1bfeca0")
description=df$results_df[[3]]


shinyUI(fluidPage(
    
    navbarPage("Film Locations in San Francisco", id="nav",
               
               tabPanel("Interactive map",
                        div(class="outer",
                            leafletOutput("map", width="100%", height=800),
                            
                            
                             absolutePanel(id = "controls", class = "panel panel-default",
                                           fixed = TRUE,draggable = TRUE, top = 60, left = "auto", 
                                           right = 20, bottom = "auto",
                                           width = 330, height = "auto",
                                           h2("Explore Film Locations"),
                                           selectInput("filmname", "Film Name:", unique(film_loc$Title)),
                                           selectInput("location", "Location:", choices = NULL),
                                           textOutput("FunFacts", height=250),
                                           plotOutput("wordcloud", height = 350)
                                           
                                           )
                            )
                        
                        ),
               tabPanel("news"
                        
               )
               
               )
    
))
