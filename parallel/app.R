library(shiny)
library(future)
library(promises)
plan(multiprocess)

helper <- function(iteration = 0) {
    res <- httr::GET("https://colorado.rstudio.com/rsc/plumber-load-test/echo?sleep=3&msg='hello'&copies=10")
    return(res)
}

ui <- fluidPage(

    titlePanel("Shiny HTTP Futures"),

    sidebarLayout(
        sidebarPanel(
            actionButton("try", "Try Again")
        ),

        mainPanel(
            textOutput("output1"),
            textOutput("output2"),
            textOutput("output3"),
            textOutput("output4"),
            textOutput("output5")
        )
    )
)

server <- function(input, output) {
    time_taken <- reactiveVal(0)

    button_click <- reactiveVal(0)

    var1 <- eventReactive(input$try, future({helper(1)}))
    var2 <- eventReactive(input$try, future({helper(2)}))
    var3 <- eventReactive(input$try, future({helper(3)}))
    var4 <- eventReactive(input$try, future({helper(4)}))
    var5 <- eventReactive(input$try, future({helper(5)}))

    output$output1 <- renderText(var1() %...>% print() %...>% capture.output())
    output$output2 <- renderText(var2() %...>% print() %...>% capture.output())
    output$output3 <- renderText(var3() %...>% print() %...>% capture.output())
    output$output4 <- renderText(var4() %...>% print() %...>% capture.output())
    output$output5 <- renderText(var5() %...>% print() %...>% capture.output())

}

shinyApp(ui = ui, server = server)
