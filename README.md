# Genomic Variant Browser

## Quickstart

### Running from Command Line Interface (CLI)

1. Make sure Git is pre-installed and clone this repository.

```
$ git clone git@github.com:liberaliscomputing/genomic-variant-browser.git
$ cd genomic-variant-browser
```

2. On the current directory, create `.env` with the following environment variables polulated:

```
# FHIR credentials
FHIR_API=<fhir-api>
FHIR_COOKIE=<your-cookie>
```

3. Make sure R is pre-installed and run the following command.

```
$ ./scripts/entrypoint.sh
```

4. An R Shiny web application rendering the genomic variant resources is available at http://localhost:3838.

### Running from a Docker Network

If you think following the above steps is a hassle, you can simpy run it in a Docker network because we are living in a world of containers 🐳🐳

1. Make sure Git is pre-installed and clone this repository.

```
$ git clone git@github.com:liberaliscomputing/genomic-variant-browser.git
$ cd genomic-variant-browser
```

2. On the current directory, create `.env` with the following environment variables polulated:

```
# FHIR credentials
FHIR_API=<fhir-api>
FHIR_COOKIE=<your-cookie>
```

3. Make sure Docker and Docker Compose are pre-installed.

4. Build a Docker image and run a container as follows.

```
$ docker build -t genomic-variant-browser . && docker run --rm -it genomic-variant-browser
```

5. If run successfully, an R Shiny web application rendering the genomic variant resources is available at http://localhost:3838.
