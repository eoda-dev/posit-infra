library(shiny)

albums <- data.frame(
  year = c(1958, 1959, 1960, 1961, 1963, 1965, 1965),
  title = c(
    "Blue Train", "Giant Steps", "My Favorite Things", "Africa/Brass",
    "Ballads", "A Love Supreme", "Ascension"
  ),
  label = c(
    "Blue Note", "Atlantic", "Atlantic", "Impulse!",
    "Impulse!", "Impulse!", "Impulse!"
  )
)

facts <- c(
  "John William Coltrane was born on September 23, 1926, in Hamlet, North Carolina.",
  "He played tenor and soprano saxophone and is one of the most influential jazz musicians ever.",
  "He played with Dizzy Gillespie, Miles Davis and Thelonious Monk before leading his own groups.",
  "'Giant Steps' (1959) introduced the 'Coltrane changes', a famously demanding chord progression.",
  "His classic quartet featured McCoy Tyner (piano), Jimmy Garrison (bass) and Elvin Jones (drums).",
  "'A Love Supreme' (1965) is a four-part spiritual suite and one of the best-selling jazz albums.",
  "Critics described his dense, rapid runs of notes as 'sheets of sound'.",
  "He died on July 17, 1967, in Huntington, New York, at the age of 40."
)

ui <- fluidPage(
  titlePanel("John Coltrane (1926-1967)"),
  sidebarLayout(
    sidebarPanel(
      p("American jazz saxophonist and composer."),
      actionButton("next_fact", "Tell me another fact"),
      hr(),
      sliderInput(
        "years", "Show albums released between",
        min = 1958, max = 1965, value = c(1958, 1965), sep = ""
      )
    ),
    mainPanel(
      h3("Did you know?"),
      wellPanel(textOutput("fact")),
      h3("Selected albums"),
      tableOutput("albums")
    )
  )
)

server <- function(input, output, session) {
  output$fact <- renderText({
    input$next_fact
    sample(facts, 1)
  })

  output$albums <- renderTable({
    albums[albums$year >= input$years[1] & albums$year <= input$years[2], ]
  }, digits = 0)
}

shinyApp(ui, server)
