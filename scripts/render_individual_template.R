#knit individual report and move .rmd to work
r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
list.of.packages <- c("rmarkdown", "optparse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) {message(paste0("Installing ", new.packages))
  install.packages(new.packages, INSTALL_opts = '--no-lock')}
invisible(sapply(list.of.packages, library, character.only = TRUE))

if(length(new.packages)) {message(paste0("Installing ", new.packages))
install.packages(new.packages, INSTALL_opts = '--no-lock')}
invisible(sapply(list.of.packages, library, character.only = TRUE))

option_list = list(
  make_option(c("-s", "--subj"), type="character", default="subj", 
              help='[Required] subj ID, e.g. "sub-015c"'),
  make_option(c("-r", "--rmd"), type="character", default=getwd(), 
              help='[Required] path to .Rmd template')

); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser,);

rmarkdown::render(opt$rmd, 
                  params = list(
                  subj = opt$subj
                  ))

