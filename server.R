#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library("DT")
library("RCurl")
#install.packages("DT")
#install.packages("RCurl")
#install.packages("ggplot2")
library(DT)
library(RCurl)
library(ggplot2)
require(RCurl)
library(reshape2)
library(plotly)

airlines <-read.csv(text=getURL("https://raw.githubusercontent.com/fivethirtyeight/data/master/airline-safety/airline-safety.csv"), header=T)



function(input, output){
  
  #Set a URL for 538
  url<- a("FiveThirtyEight.", href="https://fivethirtyeight.com/features/should-travelers-avoid-flying-airlines-that-have-had-crashes-in-the-past/")
  output$link<-renderUI({
    tagList("For a more in-depth analysis head over to", url)
  })
  
  options(scipen=1000)
  
  #Pick out an airline
  tooltip<-function(x){
    if (is.null(x)) return(NULL)
    if (is.null(x$airline)) return(NULL)
    }
  
  #Incidents Scatterplot
  lin1=lm(incidents_85_99~avail_seat_km_per_week, data=airlines)
  lin2=lm(incidents_00_14~avail_seat_km_per_week, data=airlines)
  output$plot3<-renderPlot({
    plot(airlines$avail_seat_km_per_week, airlines$incidents_85_99, col="blue", pch=20,
         xlab="Available Seat KM per Week", ylab="# Incidents")
    abline(lin1, col="blue")
    abline(lin2, col="red")
    points(airlines$avail_seat_km_per_week, airlines$incidents_00_14, col="red", pch=15)
    legend("topright",
           legend=c("1985-1999", "2000-2014"),
           col=c("blue", "red"),
           pch=c(20,15), title="Years")
  })
  #Render Info for Incidents
  output$info3<-renderText({
    paste0("Available Seat KM per Week=", input$plot_click$x, "\nIncidents=", input$plot_click$y)
  })
  
  
  #Fatalities Scatterplot
  output$plot4<-renderPlot({
    plot(airlines$avail_seat_km_per_week, airlines$fatalities_85_99, col="blue", pch=20,
         xlab="Available Seat KM per Week", ylab="# Fatalities")
    points(airlines$avail_seat_km_per_week, airlines$fatalities_00_14, col="red", pch=15)
    legend("topright",
           legend=c("1985-1999", "2000-2014"),
           col=c("blue", "red"),
           pch=c(20,15), title="Years")
  })
  #Render Info for Fatalities
  output$info4<-renderText({
    paste0("Available Seat KM per Week=", input$plot_click$x, "\nFatalities=", input$plot_click$y)
  })
  
  
  #Data table: filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data<-airlines
    if(input$airline!="All") {
      data<-data[data$airline==input$airline,]
    }
    data
  }))
  
  
  #Heatmap
  vars=c("incidents_85_99", "incidents_00_14")
  heat_data=airlines[vars]
  row.names(heat_data)<-airlines$airline
  heat_data<-heat_data[order(airlines$airline,decreasing=FALSE),]
  air_matrix<-data.matrix(heat_data)

  nms=row.names(heat_data)<-airlines$airline

  output$heat <-renderPlotly({plot_ly(x=vars, y=nms, z=air_matrix, colors=c("white", "blue"),type="heatmap", source="heatplot") %>%
      layout(xaxis=list(title=""),
             yaxis=list(title=""), height=1000, width=430, 
             margin=list(l=200, b=100))
    })
  
  
  
  vars1=c("fatalities_85_99", "fatalities_00_14")
  heat_data1=airlines[vars1]
  row.names(heat_data1)<-airlines$airline
  heat_data1<-heat_data1[order(airlines$airline,decreasing=FALSE),]
  air_matrix1<-data.matrix(heat_data1)
  
  nms1=row.names(heat_data1)<-airlines$airline
  
  output$heat1 <-renderPlotly({plot_ly(x=vars1, y=nms1, z=air_matrix1, colors=c("yellow", "red"),type="heatmap", source="heatplot") %>%
      layout(xaxis=list(title=""),
             yaxis=list(title=""), height=1000, width=430, 
             margin=list(l=200, b=100))
  })
  
  
  #Standardizing incidents
  airlines["fatal_per_seat99"]=as.numeric(airlines$fatalities_85_99)/(airlines$avail_seat_km_per_week)*1000000
  airlines["fatal_per_seat14"]=as.numeric(airlines$fatalities_00_14)/(airlines$avail_seat_km_per_week)*1000000
  airlines["incid_per_seat99"]=as.numeric(airlines$incidents_85_99)/(airlines$avail_seat_km_per_week)*1000000
  airlines["incid_per_seat14"]=as.numeric(airlines$incidents_00_14)/(airlines$avail_seat_km_per_week)*1000000
  
  counts<- table(airlines$fatal_per_seat99, airlines$airline)
  output$perseat <- renderPlotly({
    plot_ly(x=airlines$airline, y=airlines$fatal_per_seat99, type="bar", name="1985-1999", height=500, width=1200) %>%
      add_trace(y=airlines$fatal_per_seat14, name="2000-2014") %>%
      layout(yaxis=list(title="Fatalities per Seat (Million) KM/ Week"), barmode='group', margin=list(b=200))
    
  })
  
  
  counts1<- table(airlines$incid_per_seat99, airlines$airline)
  output$perseat1 <- renderPlotly({
    plot_ly(x=airlines$airline, y=airlines$incid_per_seat99, type="bar", name="1985-1999", height=500, width=1200) %>%
      add_trace(y=airlines$incid_per_seat14, name="2000-2014") %>%
      layout(yaxis=list(title="Incidents per Seat (Million) KM/ Week"), barmode='group', margin=list(b=200))
    
  })
  
}

  
  
