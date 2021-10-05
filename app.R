source("global.R", local = TRUE)


# UI component
ui <- navbarPage(
    "Genomic Variant Browser",
    tabPanel(
        "Genomics Report",
        sidebarLayout(
            sidebarPanel(uiOutput("select"), width = 2),
            # mainPanel(DT::dataTableOutput("resources"), width = 10)
            mainPanel(
                tabsetPanel(
                    type = "tabs",
                    tabPanel("Demographics", verbatimTextOutput("demographics")),
                    tabPanel("Diseases", verbatimTextOutput("diseases")),
                    tabPanel("Variants", verbatimTextOutput("variants"))
                )
                
            )
        )
    )
)


# server component
server <- function(input, output) {
    datat_input <- reactive({
        base_url = trimws(fhir_api, which = "right", whitespace = "/")
        patient_id = patient_df[patient_df$research_id == input$subject, ]$patient_id
        results <- list()

        # demographcs
        demographics <- paste(
            base_url,
            glue("Patient/{patient_id}"),
            sep="/"
        )
        demographics <- get_request(demographics, fhir_cookie)
        results[["demographics"]] <- demographics

        # diseases
        diseases <- paste(
            base_url,
            glue("Condition?subject=Patient/{patient_id}"),
            sep="/"
        )
        diseases <- paginate(diseases, fhir_cookie)
        results[["diseases"]] <- diseases

        # variants
        variants <- paste(
            base_url,
            glue("Observation?_profile:below=http://hl7.org/fhir/uv/genomics-reporting/StructureDefinition/variant&subject=Patient/{patient_id}"),
            sep="/"
        )
        variants <- paginate(variants, fhir_cookie)
        results[["variants"]] <- variants

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

    output$demographics <- renderText({
        jsonlite::prettify(
            jsonlite::toJSON(datat_input()[["demographics"]], auto_unbox = TRUE), 2
        )
    })

    output$diseases <- renderText({
        jsonlite::prettify(
            jsonlite::toJSON(datat_input()[["diseases"]], auto_unbox = TRUE), 2
        )
    })

    output$variants <- renderText({
        jsonlite::prettify(
            jsonlite::toJSON(datat_input()[["variants"]], auto_unbox = TRUE), 2
        )
    })
}

# Bind UI and server to an application
shinyApp(ui = ui, server = server)
