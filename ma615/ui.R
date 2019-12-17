library(shiny)
library(leaflet)
library(maps)
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)
library(plotly)
library(newsanchor)
library(wordcloud)

film_loc=read.csv("/Users/tsuyu/Downloads/workspace/ma615_1216/film_loc.csv")
film_loc %<>% 
    #unifying the names of production companies
    mutate(Production.Company=as.character(Production.Company)) %>%
    mutate(`Production Company`=ifelse(str_detect(Production.Company, "Columbia Pictures"), "Columbia Pictures Corp.", ifelse(str_detect(Production.Company, "Metro-Goldwyn"), "Metro-Goldwyn Mayor", ifelse(str_detect(Production.Company, "Orion Pictures"), "Orion Pictures Corp.", ifelse(str_detect(Production.Company, "PYM Particles"), "PYM Particles Production, LCC", ifelse(str_detect(Production.Company, "Twentieth Century Fox"), "Twentieth Century Fox Film Coorp.", ifelse(str_detect(Production.Company, "Warner Bro"), "Warner Bros. Pictures", Production.Company))))))) %>%
    select(-Production.Company)
film_loc$Distributor=as.character(film_loc$Distributor) 

#query dataset for fun facts
funfacts=film_loc %>% select(Title, Locations, Fun.Facts) %>% filter(Fun.Facts!="")
funfacts$Title=as.character(funfacts$Title)
funfacts$Locations=as.character(funfacts$Locations)

#query dataset for Production Company(for plot1)
ProdComp <- film_loc %>% select(Title, `Production Company`, )

#get news San Francisco for wordcloud 
df <- get_everything(query = "san francisco", sort_by = "relevancy", page = 1, page_size = 100, api_key ="6572647b5bd941efa75620ffe1bfeca0")
description=df$results_df[[3]]

#define news category selection
category=c("Breaking News", "Sports", "Politics", "Technology", "Weather", "Business")


shinyUI(
    
    
    fluidPage(
    
    navbarPage("Film Locations in San Francisco", id="nav",
               #tabPanel
               tabPanel("San Francisco Map",
                        div(class="outer",
                            leafletOutput("map", width="100%", height=800),
                            
                            
                             absolutePanel(id = "controls", class = "panel panel-default",
                                           fixed = TRUE, draggable = TRUE, top = 60, left = "auto", 
                                           right = 20, bottom = "auto",
                                           width = 400, height = "auto",
                                           h2("Explore Film Locations"),
                                           selectInput("filmname", "Film Name:", unique(funfacts$Title)),
                                           selectInput("location", "Location:", choices = NULL),
                                           h3("FUN Facts"),
                                           textOutput("FunFacts"),
                                           h4("Production Company"),
                                           plotlyOutput("plot1", height = 400)
                                           
                                           
                                           )
                            )
                        
                        ),
               #a second tabPanel
               tabPanel("News",
                        absolutePanel(id = "right-side", class = "panel panel-default",
                                      fixed = TRUE, draggable = TRUE, top = 300, left = 20, 
                                      right = "auto", bottom = "auto",
                                      width = 400, height = "auto",
                                      h2("SF Keywords from this month"),
                                      plotOutput("wordcloud", height = 450)
                        ),
                        sidebarPanel(
                            selectInput("category", "News Category:", category),
                            width = 4
                        ),
                        mainPanel(
                            tableOutput("news")
                        )
                        
               )
               
               )
    
))
