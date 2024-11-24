#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh

asdf install haskell ${HASKELL_VER}
asdf global haskell ${HASKELL_VER}

asdf install erlang ${ERLANG_VER}
asdf global erlang ${ERLANG_VER}

asdf install elixir ${ELIXIR_VER}
asdf global elixir ${ELIXIR_VER}

asdf install golang ${GOLANG_VER}
asdf global golang ${GOLANG_VER}

asdf install python ${PYTHON_VER}
asdf global python ${PYTHON_VER}

R_EXTRA_CONFIGURE_OPTIONS='--enable-R-shlib --with-cairo' asdf install r ${R_VER}
asdf global r ${R_VER}

# rstudio
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-${RSTUDIO_DEB}-${RSTUDIO_ARCH}.deb
sudo gdebi rstudio-${RSTUDIO_DEB}-${RSTUDIO_ARCH}.deb

# pipenv
#pip install pipenv
# example usage
#cd ~/dev/my-python-project
#pipenv --python 3.12.7
#pip install pandas matplotlib scipy numpy jupyterlab polars pint pint-pandas
# env. can now be selected in vscode using Python: Select Interpreter

sudo apt-get install build-essential chrpath libssl-dev libxft-dev -y
sudo apt-get install libfreetype6 libfreetype6-dev -y
sudo apt-get install libfontconfig1 libfontconfig1-dev -y

set +H
declare -a R_PKGS=(
"arrow"
"babynames"
"BiocStyle"
"BiocGenerics"
"blogdown"
"bookdown"
"bookmarkdown"
"Cairo"
"devtools"
"downlit"
"dplyr"
"duckdb"
"esc"
"forcats"
"formatR"
"ggforce"
"ggplot2"
"ggraph"
"ggridges"
"ggthemes"
"gifski"
"gutenbergr"
"httpgd"
"igraph"
"janeaustenr"
"janitor"
"jsonlite"
"kableExtra"
"knitractive"
"Lahman"
"languageserver"
"leaflet"
"lobstr"
"lubridate"
"magick"
"mallet"
"Matrix"
"mindr"
"NutrienTrackeR"
"nycflights13"
"openxlsx"
"OpenImageR"
"palmerpenguins"
"pdftools"
"pivottabler"
"plotrix"
"quanteda"
"radian"
"raster"
"readr"
"repurrrsive"
"reshape2"
"reticulate"
"rmarkdown"
"rticles"
"scater"
"sessioninfo"
"shiny"
"stargazer"
"stevedata"
"stringr"
"styler"
"textdata"
"terra"
"tidymodels"
"tidyr"
"tidytext"
"tidyverse"
"tinytex"
"tm"
"topicmodels"
"webshot"
"widyr"
"wordcloud"
"writexl"
"XML"
)
for R_PKG in "${R_PKGS[@]}"
do
  Rscript -e "if (!require('${R_PKG}')) install.packages('${R_PKG}', repos='https://cloud.r-project.org')"
done

# knitr command line, repo: https://github.com/sachsmc/knit-git-markr-guide
Rscript -e "rmarkdown::render('brb-talk.Rmd','pdf_document')"
# TOC and stargazer pdf issue. Try:
#   pdf_document:
#     keep_tex: true
#     toc: true
#     toc_depth: 2
#
# ```{r star, results = 'asis', warning=FALSE, message=FALSE, verbatim = TRUE}
# library(stargazer, quietly = TRUE)
# fit1 <- lm(mpg ~ wt, mtcars)
# fit2 <- lm(mpg ~ wt + hp, mtcars)
# fit3 <- lm(mpg ~ wt + hp + disp, mtcars)
# stargazer(fit1, fit2, fit3, type = 'latex', header=FALSE)

# sudo apt install -y default-jre default-jdk r-cran-rjava
# sudo R CMD javareconf
# "xlsx"

