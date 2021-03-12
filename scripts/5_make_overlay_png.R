
r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
list.of.packages <- c("optparse", "neurobase", "grDevices", "oro.nifti", "ggplot2", "grid", "gridExtra", "png")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]


if(length(new.packages)) {message(paste0("Installing ", new.packages))
  install.packages(new.packages, INSTALL_opts = '--no-lock')}
invisible(sapply(list.of.packages, library, character.only = TRUE))

option_list = list(
  make_option(c("-f", "--fmri"), type="character", default=NULL, 
              help="[Required] Path to fmri scan"),
  make_option(c("-a", "--atlas"), type="character", default=NULL, 
              help="[Required] Path to atlas"),
  make_option(c("-s", "--subj"), type="character", default="subj", 
              help='[Optional] subj ID, e.g. "sub-015c"'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(), '/'), 
              help='[Optional] Directory to output  image'),
  make_option(c("-w", "--work"), type="character", default=paste0(getwd(), '/'), 
              help='[Optional] Directory to work folder'),
  make_option(c("-g", "--gap"), type="double", default=5, 
              help='[Optional] Gap between slices shown [Default = 5), i.e. every 5th slice is shown')
  
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser,);

if (is.null(opt$fmri) | is.null(opt$atlas)){
  print_help(opt_parser)
  stop("Atleast two arguments must be supplied (fmri and atlas, eg. -f fmri.nii -a atlas.nii)", call.=FALSE)
}


fmri <- neurobase::readNIfTI2(opt$fmri)
atlas <- neurobase::readNIfTI2(opt$atlas)


alpha = function(col, alpha = 1) {
  cols = t(col2rgb(col, alpha = FALSE)/255)
  rgb(cols, alpha = alpha)
}

dim <- dim(fmri)[3]
slice <- seq(from = 1, to = dim, by = opt$gap)

png(file=paste0(opt$work,opt$subj,"_%03d.png"), width=200, height=200)
for (i in slice){
oro.nifti::overlay(x=fmri, y = atlas, z = i,w=1, 
                                        plot.type = "single", 
                                        col.y=alpha(rainbow(500), 0.3),
                                        NA.y=T)
}
dev.off()

pnglist <- list.files(path = opt$work, pattern  = '.png', full.names = TRUE)


plots <- lapply(ll <- list.files(path = opt$work, pattern  = '.png', full.names = TRUE),function(x){
  img <- as.raster(readPNG(x))
  rasterGrob(img, interpolate = FALSE)
})

ggsave(paste0(opt$out,opt$subj,"_overlay.png"),
       marrangeGrob(grobs = plots, 
                    nrow=ceiling(sqrt(length(slice))), 
                    ncol=ceiling(sqrt(length(slice))),
                    top=NULL))


