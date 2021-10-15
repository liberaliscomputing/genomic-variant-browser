#!/bin/bash

# Usage ./scripts/run_app.sh [ app_dir ] [ port ] [ host ]

set -eo pipefail

APP_DIR=${1:-$(pwd)}
PORT=${2:-3838}
HOST=${3:-0.0.0.0}

R -e "shiny::runApp(appDir = \"$APP_DIR\", port = $PORT, host = \"$HOST\")"
