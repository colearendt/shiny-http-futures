# Shiny HTTP Futures

An example pattern of using `promises` and `futures` with a Shiny app and HTTP requests.

## How to use

- see [`./no_parallel/app.R`](./no_parallel/app.R) for an example of serial requests
- see [`./parallel/app.R`](./parallel/app.R) for an example of parallelized requests
- you can increase the "number of requests" by copying / pasting in a few places
- you can tweak how long each request takes
- there is a timer that is triggered / resolved manually (sorry... this was the easiest way to time...)
- pull requests are welcome!

## Performance

- For 5 requests, 2 seconds per request, the difference is ~ 8 seconds vs. ~ 12
seconds.
- Things get better for more requests or longer requests. For instance, 5
requests, 3 seconds per request, the difference is ~ 10 sec vs. ~ 18 seconds.
- Adding parallelization increases the actual system resources required (there
is overhead for starting new processes)
- The parallelized requests run outside of Shiny, so things like
`showNotification()` or other Shiny session references will not be available
- If using parallelization, _EVERY CHILD REQUEST_ must be piped. No function
calls without the `%...>%` pipe or the promise-chain will break
- NOTE: Even with parallelization, the _slowest request_ gates _all_ of the
reactives returning. I.e. making one request 6 seconds will slow _everything_
down, since the UI will not render until all reactive components are computed.
    - This will be addressed / improved once [this
    issue](https://github.com/rstudio/shiny/issues/1705) and [this
    one](https://github.com/rstudio/promises/issues/23#issuecomment-386687705)
    are resolved. Please vote!!

## Some Notes

- If your requests are very fast, or if you have only a few of them, the
additional overhead of starting processes is probably not worth it. The more
requests / more
- Remember: _everything must be a pipe_ if you want to use this paradigm
- This is probably best implemented with _computation_ caching with
[`memoise`](https://github.com/r-lib/memoise) or _output_ caching with [plot
caching](https://shiny.rstudio.com/articles/plot-caching.html) so that _when
computing_ things are managable, but _computation is needed less frequently_.
- [More reading on promises](https://rstudio.github.io/promises/articles/shiny.html)

## Differences

To highlight the differences between the app approaches:

```
$ diff no_parallel/app.R parallel/app.R -y --suppress-common-lines
    titlePanel("Shiny HTTP Futures - No Parallel"),           |     titlePanel("Shiny HTTP Futures - Parallel"),
    var1 <- eventReactive(input$try, helper(1))               |     var1 <- eventReactive(input$try, future({helper(1)}))
    var2 <- eventReactive(input$try, helper(2))               |     var2 <- eventReactive(input$try, future({helper(2)}))
    var3 <- eventReactive(input$try, helper(3))               |     var3 <- eventReactive(input$try, future({helper(3)}))
    var4 <- eventReactive(input$try, helper(4))               |     var4 <- eventReactive(input$try, future({helper(4)}))
    var5 <- eventReactive(input$try, helper(5))               |     var5 <- eventReactive(input$try, future({helper(5)}))
                                                              |
    output$output1 <- renderText(var1() %>% print() %>% captu |     output$output1 <- renderText(var1() %...>% print() %...>%
    output$output2 <- renderText(var2() %>% print() %>% captu |     output$output2 <- renderText(var2() %...>% print() %...>%
    output$output3 <- renderText(var3() %>% print() %>% captu |     output$output3 <- renderText(var3() %...>% print() %...>%
    output$output4 <- renderText(var4() %>% print() %>% captu |     output$output4 <- renderText(var4() %...>% print() %...>%
    output$output5 <- renderText(var5() %>% print() %>% captu |     output$output5 <- renderText(var5() %...>% print() %...>%
```
