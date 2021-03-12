# set up prereqs

#trying to make the master file in r
r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
list.of.packages <- c("optparse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]


if(length(new.packages)) {message(paste0("Installing ", new.packages))
  install.packages(new.packages, INSTALL_opts = '--no-lock')}
invisible(sapply(list.of.packages, library, character.only = TRUE))

kableExtra