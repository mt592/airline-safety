#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# This Shiny App explores a simple dataset on Airline safety. 
# 
#    
#

library(shiny)
library(plotly)
require(RCurl)
library(shinythemes)
#Get data from FiveThirtyEight github
airlines <-read.csv(text=getURL("https://raw.githubusercontent.com/fivethirtyeight/data/master/airline-safety/airline-safety.csv"), header=T)


# Define server logic required to draw a histogram
fluidPage( theme=shinytheme("yeti"),
  titlePanel(tags$b("Airline Safety Exploration")),
  fluidRow(
    column(12, h4("Airline safety data courtesy of FiveThirtyEight. Data includes number of incidents, fatalities, and fatal accidents from 1985 to 2014.")
    ),
    column(12, uiOutput("link"))
    ),
  column(12, HTML("   ", '<br/>')),

  #Create new row for table
  mainPanel(
    tabsetPanel(
      
      #Tab 1
      tabPanel("Scatter Plots",
               
               #Display Incident plot
               fluidRow(
                 column(6, h5(tags$b("Plot of Incidents per Available Seat KM")), offset=4),
                 column(12, h6("In general, we can see that the more available kilometer seats per week an airline has, the more indicents occur. Except for a few outliers, the trend looks fairly linear. It also looks like advances in technology, have allowed more recent years to result in fewer incidents.")),
                 column(12, plotOutput("plot3", click="plot_click")),
                 column(12, verbatimTextOutput("info3"))
                 ),
               
               #Display Fatalities plot
               fluidRow(
                 column(6, h5(tags$b("Plot of Fatalities per Available Seat KM")), offset=4),
                 column(12, h6("Unlike our plot depicting incidents, fatalities and available seat KMs are not linearly related. Many airlines, especially in the years 2000-2014 had zero fatalities. Furthermore it looks like airlines that have less available seat KMs have more fatalities- perhaps due to the danger of smaller planes or inexperience from fewer flights.")),
                 column(12, plotOutput("plot4", click="plot_click")),
                 column(12, verbatimTextOutput("info4"))
                )
               ),
      
      #Tab 2
      tabPanel("Heatmap",
        #Create new Rows in UI for selectInputs
        fluidRow(
          column(12, h6("With darker colors representing higher instances of incidents and fatalities, we can see that a high level of pre-2000 incidents/fatalities do not necessarily indicate a high level of fatalities in the 21st century. Malaysia airlines for example, which had relatively few fatalities in the pre-2000, surged in fatalities in the next 14 year period.")),
          column(3, h5(tags$b("Incident Heatmap")), offset=3),
          column(3, h5(tags$b("Fatality Heatmap")), offset=3),
          column(6, offset=0,
                 fluidRow(plotlyOutput("heat"))
                 ),
          column(6, offset=0,
                 fluidRow(plotlyOutput("heat1"))
          )
          
          )
        ),
      
      #Tab 3
      tabPanel("Standardized Plots",
               fluidRow(
                 column(12, "Calculating fatalities per available seat kilometers flown, changes the story of our data a bit. 
                               For example, Aeroflot which has many incidents also has a greater number of seat kilometers flown 
                               in a given week. This could mean either it has more flights, or is flying larger planes. This indicates 
                               that percentage-wise, not too many Aeroflot flights result in death. Conversely, Kenya Airways has a huge 
                               number of fatalities per seat kilometers flown- comparitively a high percentage of their flights result in death."),
               column(12, h5(tags$b("Fatalities per Seat"))),
               column(12, plotlyOutput("perseat")),
               column(12, HTML("   ", '<br/>')),
               column(12, HTML("   ", '<br/>'))
                 ),
               fluidRow(
                 column(12, "If we compare the Incidents plot below to the Fatalities plot above, we can also pretty clearly see that incidents don't directly translate to deaths. This would indicate that in general, there are fewer but more fatal accidents when it comes to flying."),
                 column(12, h5(tags$b("Incidents per Seat"))),
                 column(12, plotlyOutput("perseat1"))
                  )
               ),
      
      #Tab 4
      tabPanel("Raw Data",
               #Create new Rows in UI for selectInputs
               fluidRow(
                 column(12,
                        selectInput("airline", 
                                    "Choose an Airline:", 
                                    c("All", unique(as.character(airlines$airline))))
                 )
               ),
               
               fluidRow(
                 DT::dataTableOutput("table")
               )
               
      )
        ) #end tabsetPanel
      )
    )
  





