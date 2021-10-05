# build on base image from https://hub.docker.com/r/rocker/shiny
FROM rocker/shiny:latest

# set working directory
WORKDIR app/

# Setup deps
RUN apt-get -y update && apt-get install -y gcc libpq-dev

# copy necessary files
COPY .env ./
COPY global.R ./
COPY app.R ./
COPY ./scripts/ app/scripts/

# install dependencies
RUN R -e "install.packages(\"dotenv\")"
RUN R -e "install.packages(\"httr\")"
RUN R -e "install.packages(\"glue\")"
RUN R -e "install.packages(\"shiny\")"
RUN R -e "install.packages(\"jsonlite\")"
RUN R -e "install.packages(\"DT\")"

# expose port
EXPOSE 3838

# run app on container start
CMD ["app/scripts/entrypoint.sh"]
