# Start (from this folder): Rscript -e 'shiny::runApp(port = 8080, launch.browser = FALSE)'
#
# Connects via the ODBC DSN from ODBCINI_DSN (default: postgresql-test), lists the
# tables in the schema from PG_SCHEMA (default: public) and shows the first five
# rows of the selected table.

library(shiny)

dsn <- Sys.getenv("ODBCINI_DSN", "postgresql-test")
schema <- Sys.getenv("PG_SCHEMA", "public")

ui <- fluidPage(
  titlePanel("DB inspector"),
  sidebarLayout(
    sidebarPanel(
      p(strong("DSN: "), dsn),
      p(strong("Schema: "), schema),
      uiOutput("table_select")
    ),
    mainPanel(
      uiOutput("status"),
      h3(textOutput("table_title")),
      tableOutput("preview")
    )
  )
)

server <- function(input, output, session) {
  # One connection per session; keep the error message if connecting fails
  con <- tryCatch(
    odbc::dbConnect(odbc::odbc(), dsn = dsn),
    error = function(e) e
  )
  connected <- inherits(con, "DBIConnection")
  if (connected) {
    session$onSessionEnded(function() DBI::dbDisconnect(con))
  }

  tables <- reactive({
    req(connected)
    sort(odbc::dbListTables(con, schema_name = schema))
  })

  output$status <- renderUI({
    if (!connected) {
      return(tags$pre(paste("Connection error:", conditionMessage(con))))
    }
    n <- tryCatch(length(tables()), error = function(e) e)
    if (inherits(n, "error")) {
      tags$pre(paste("Error listing tables:", conditionMessage(n)))
    } else if (n == 0) {
      p("No tables found in schema ", code(schema), ".")
    }
  })

  output$table_select <- renderUI({
    req(connected, length(tables()) > 0)
    selectInput("table", "Table", choices = tables())
  })

  output$table_title <- renderText({
    req(input$table)
    paste0(schema, ".", input$table, " (first 5 rows)")
  })

  output$preview <- renderTable({
    req(input$table)
    tbl <- DBI::dbQuoteIdentifier(con, DBI::Id(schema = schema, table = input$table))
    DBI::dbGetQuery(con, paste("SELECT * FROM", tbl, "LIMIT 5"))
  })
}

shinyApp(ui, server)
