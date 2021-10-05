required_packages <- c(
    "dotenv",
    "httr",
    "glue",
    "shiny",
    "jsonlite",
    "DT"
)

# install or load dependencies
for (package in required_packages) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package)
        library(package, character.only = TRUE)
    }
}

# load environmental variables
load_dot_env()
fhir_api <- Sys.getenv("FHIR_API")
fhir_cookie <- Sys.getenv("FHIR_COOKIE")

# define custom functions
get_request <- function(url, cookie) {
    resp <- GET(
        url, add_headers(ContentType = "application/json+fhir", Cookie = cookie)
    )

    # raise for status
    stop_for_status(resp)

    return(content(resp, as = "parsed", type = "application/json"))
}

paginate <- function(url, cookie) {
    resources <- list()
    page <- url
    while (!is.null(page)) {
        body <- get_request(page, cookie)

        entry <- body$entry
        if (!is.null(entry)) {
            resources <- append(
                resources, lapply(entry, function(x) {return(x$resource)})
            )
        }

        page <- NULL
        for (link in body$link) {
            if (link$relation == "next") {
                page <- gsub(
                    "http://localhost:8000",
                    trimws(fhir_api, which = "right", whitespace = "/"),
                    link$url
                )
                break
            }
        }
    }

    return(resources)
}


# query patients having genomics_report
query_string <- paste(
    trimws(fhir_api, which = "right", whitespace = "/"),
    "Patient?_has:DiagnosticReport:subject:code=81247-9",
    sep="/"
)
patients <- paginate(query_string, fhir_cookie)

# TODO: refactor the lines below in a fancier R way
patient_ids <- c()
research_ids <- c()
for (patient in patients) {
    patient_ids <- c(patient_ids, patient$id)
    research_ids <- c(research_ids, patient$identifier[[1]]$value)
}

patient_df = cbind(
    as.data.frame(patient_ids),
    as.data.frame(research_ids)
)
names(patient_df) <- c("patient_id", "research_id")
