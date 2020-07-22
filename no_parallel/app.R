library(shiny)

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
            h3(textOutput("time"))
        )
    )
)

server <- function(input, output) {
    time_taken <- reactiveVal(0)

    var1 <- reactiveVal(NA)
    var2 <- reactiveVal(NA)
    var3 <- reactiveVal(NA)
    var4 <- reactiveVal(NA)
    var5 <- reactiveVal(NA)

    observeEvent(input$try, {
        start <- Sys.time()

        var1(helper(1))
        var2(helper(2))
        var3(helper(3))
        var4(helper(4))
        var5(helper(5))

        finished <- Sys.time()
        elapsed <- finished - start
        time_taken(elapsed)
    })

    output$time <- renderText({
        if(time_taken() == 0) {
            "Please click the button!"
        } else {
            glue::glue("It took {time_taken()} seconds to fire 5 requests")
        }
    })

}

shinyApp(ui = ui, server = server)
