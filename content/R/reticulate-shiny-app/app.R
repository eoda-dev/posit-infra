# Start (from this folder): Rscript -e 'shiny::runApp(port = 8080, launch.browser = FALSE)'
#
# Shiny app that calls Python via reticulate. It only uses the Python standard
# library, so no extra Python packages are needed. Set RETICULATE_PYTHON to pick
# a specific interpreter, otherwise reticulate chooses one.

library(shiny)
library(reticulate)

# Python code defined inline, available as py$<name> in R
py_run_string("
import platform
import statistics

def describe(values):
    return {
        'n': len(values),
        'mean': statistics.mean(values),
        'median': statistics.median(values),
        'stdev': statistics.stdev(values) if len(values) > 1 else 0.0,
    }
")

ui <- fluidPage(
  titlePanel("reticulate example"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Number of random values", min = 2, max = 500, value = 100),
      actionButton("resample", "Draw new values")
    ),
    mainPanel(
      h3("Python environment"),
      verbatimTextOutput("py_info"),
      h3("Summary computed in Python"),
      tableOutput("stats"),
      h3("Values (drawn in R)"),
      plotOutput("hist", height = "250px")
    )
  )
)

server <- function(input, output, session) {
  values <- reactive({
    input$resample
    rnorm(input$n)
  })

  output$py_info <- renderText({
    cfg <- py_config()
    paste0(
      "Python:   ", py$platform$python_version(), "\n",
      "Binary:   ", cfg$python, "\n",
      "Platform: ", py$platform$platform()
    )
  })

  output$stats <- renderTable({
    res <- py$describe(as.list(values()))
    data.frame(statistic = names(res), value = unlist(res))
  }, digits = 3)

  output$hist <- renderPlot({
    hist(values(), main = NULL, xlab = "value", col = "grey80", border = "white")
  })
}

shinyApp(ui, server)
