#!/bin/sh
set -eu

CODENAME=$(lsb_release -cs)

sudo Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/${CODENAME}/latest')); install.packages(c('odbc'))"

