server <- function(input, output){
  output$text1 <- renderText({
    input$slider1
  })
  
  output$text2 <- renderText({
    input$select1
  })
  
  
}