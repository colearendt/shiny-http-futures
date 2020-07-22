library(shiny)
library(future)
library(promises)
plan(multiprocess)

helper <- function(iteration = 0, duration = 2) {
    res <- httr::GET(glue::glue("https://colorado.rstudio.com/rsc/plumber-load-test/echo?sleep={duration}&msg='hello'&copies=10"))
    return(res)
}

ui <- fluidPage(

    titlePanel("Shiny HTTP Futures"),

    sidebarLayout(
        sidebarPanel(
            actionButton("try", "Try Again"),
            actionButton("done", "Click when Done")
        ),

        mainPanel(
            h3(textOutput("time_text")),
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

    start_time <- reactiveVal(0)
    done_time <- reactiveVal(0)

    observeEvent(input$try, {
        start_time(Sys.time())
        done_time(0)
    })

    observeEvent(input$done, {
        done_time(Sys.time())
    })

    output$time_text <- renderText({
        if(done_time() == 0) {
            "Time not computed yet..."
        } else {
            glue::glue("Requests took {done_time() - start_time()} seconds")
        }
    })

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
