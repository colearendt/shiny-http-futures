library(shiny)
library(future)
library(promises)
plan(multiprocess)

helper <- function(iteration = 0) {
    shiny::showNotification(glue::glue("Firing request {iteration}"))
    res <- httr::GET("https://colorado.rstudio.com/rsc/plumber-load-test/echo?sleep=3&msg='hello'&copies=10")
    shiny::showNotification(glue::glue("Done with request {iteration}"))
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

    var1 <- reactive({print(input$try); helper(1)})
    var2 <- reactive({print(input$try); helper(2)})
    var3 <- reactive({print(input$try); helper(3)})
    var4 <- reactive({print(input$try); helper(4)})
    var5 <- reactive({print(input$try); helper(5)})


    output$output1 <- renderText(capture.output(print(var1())))
    output$output2 <- renderText(capture.output(print(var2())))
    output$output3 <- renderText(capture.output(print(var3())))
    output$output4 <- renderText(capture.output(print(var4())))
    output$output5 <- renderText(capture.output(print(var5())))

}

shinyApp(ui = ui, server = server)
