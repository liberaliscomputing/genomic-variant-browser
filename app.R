source("global.R", local = TRUE)


# UI component
ui <- navbarPage(
    "Genomic Variant Browser",
    tabPanel(
        "Genomics Report",
        sidebarLayout(
            sidebarPanel(uiOutput("select"), width = 2),
            mainPanel(
                tabsetPanel(
                    type = "tabs",
                    tabPanel("Demographics", DT::dataTableOutput("demographics")),
                    tabPanel("Diseases", DT::dataTableOutput("diseases")),
                    tabPanel("Variants", verbatimTextOutput("variants"))
                )
                
            )
        )
    )
)


# server component
server <- function(input, output) {
    data_input <- reactive({
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
        extension = demographics$extension
        demographics <- data.frame(
            "Subject" = c(demographics$identifier[[1]]$value),
            "Race" = c(extension[[1]]$extension[[2]]$valueCoding$display),
            "Ethnicity" = c(extension[[2]]$extension[[2]]$valueCoding$display),
            "Gender" = c(demographics$gender),
            check.names = FALSE
        )
        results[["demographics"]] <- demographics

        # diseases
        diseases <- paste(
            base_url,
            glue("Condition?subject=Patient/{patient_id}"),
            sep="/"
        )
        diseases <- paginate(diseases, fhir_cookie)

        subject <- c()
        clinical_status <- c()
        category <- c()
        code <- c()
        body_site <- c()
        onset_age <- c()
        for (disease in diseases) {
            subject <- c(subject, input$subject)
            clinical_status <- c(
                clinical_status, disease$clinicalStatus$coding[[2]]$display
            )
            category <- c(category, disease$category[[2]]$coding[[1]]$display)
            code <- c(code, disease$code$coding[[1]]$display)
            body_site <- c(body_site, disease$bodySite[[1]]$coding[[1]]$display)
            onset_age <- c(onset_age, disease$onsetAge$value)
        }
        diseases <- data.frame(
            "Subject" = subject,
            "Clinical Status" = clinical_status,
            "Disease Category" = category,
            "Dieases Code" = code,
            "Body Site" = body_site,
            "Onset Age in Days" = onset_age,
            check.names = FALSE
        )
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

    output$demographics <- DT::renderDataTable({
        data_input()[["demographics"]]
    }, options = list(pageLength = 25))

    output$diseases <- DT::renderDataTable({
        data_input()[["diseases"]]
    }, options = list(pageLength = 25))

    output$variants <- renderText({
        jsonlite::prettify(
            jsonlite::toJSON(data_input()[["variants"]], auto_unbox = TRUE), 2
        )
    })
}

# Bind UI and server to an application
shinyApp(ui = ui, server = server)
