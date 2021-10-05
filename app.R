source("global.R", local = TRUE)


# UI component
ui <- navbarPage(
    "Genomic Variant Browser",
    tabPanel(
        "Genomics Report",
        sidebarLayout(
            sidebarPanel(uiOutput("select"), width = 2),
            # mainPanel(DT::dataTableOutput("resources"), width = 10)
            mainPanel(verbatimTextOutput("resources"), width = 10)
        )
    )
)


# Server component
server <- function(input, output) {
    datatable_input <- reactive({
        filtered_df = patient_df[patient_df$research_id == input$subject, ]

        patient_id = filtered_df$patient_id

        query_string <- paste(
            trimws(fhir_api, which = "right", whitespace = "/"),
            glue("Observation?_profile:below=http://hl7.org/fhir/uv/genomics-reporting/StructureDefinition/variant&subject=Patient/{patient_id}"),
            sep="/"
        )
        variants <- paginate(query_string, fhir_cookie)

        results <- jsonlite::prettify(jsonlite::toJSON(variants, auto_unbox = TRUE), 2)

        # return(variant_df[variant_df$research_id == input$subject, ])
        return(results)
    })

    output$select <- renderUI({
        selectInput(
            "subject",
            "Select a Subject:",
            patient_df$research_id,
            selected = patient_df$research_id[1]
        )
    })

    # output$resources <- DT::renderDataTable({
    #     datatable_input()
    # }, options = list(pageLength = 25))

    output$resources <- renderText({
        datatable_input()
    })
}

# Bind UI and server to an application
shinyApp(ui = ui, server = server)
