invisible(setwd(system("pwd", intern = T)))
#r = getOption("repos")
#r["CRAN"] = "http://cran.us.r-project.org"
#options(repos = r)
list.of.packages <- c("optparse", "RColorBrewer", "ggplot2", "pheatmap")
#new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

#if(length(new.packages)) {message(paste0("Installing ", new.packages))
#  install.packages(new.packages, INSTALL_opts = '--no-lock')}
invisible(sapply(list.of.packages, library, character.only = TRUE))

option_list = list(
  make_option(c("-t", "--timeseries"), type="character", default=NULL, 
              help="[Required] Path to timeseries extracted from fmri scan"),
  make_option(c("-s", "--subj"), type="character", default="subj", 
              help='[Optional] subj ID, e.g. "sub-015c"'),
  make_option(c("-o", "--out"), type="character", default=getwd(), 
             help='[Optional] Directory to output  image'),
  make_option(c("-w", "--work"), type="character", default=getwd(), 
              help='[Optional] Directory to work folder'),
  make_option(c("-u", "--up"), type="double", default=.8, 
              help='Upper limit on colour bar [Default: .8]'),
  make_option(c("-l", "--lo"), type="double", default=-.8, 
              help='lower limit on colour bar [Default: -.8]'),
  make_option(c("-c", "--colour"), type="character", default="RdBu", 
              help='Colour pallette, can be any brewer.pal. See https://rdrr.io/cran/RColorBrewer/man/ColorBrewer.html. [Default: "RdBu"]'),
  make_option(c("-m", "--row_means"), type="logical", default=FALSE, 
              help='Write mean singal for each ROI - sueful for ROI exclusion due to poor signal.')
  
); 



opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser,);

if (is.null(opt$timeseries)){
  print_help(opt_parser)
  stop("Atleast one argument must be supplied (timeseries, eg. -t timeseries.txt)", call.=FALSE)
}


ts <- as.matrix(read.table(opt$timeseries, header = F))

#save row means for roi signal coverage check
if (opt$row_mean==T) {
  write.table(rowMeans(ts), paste0(opt$work,'/',opt$subj,"_rowmeans.txt"), 
              row.names = F, 
              col.names = F,
              quote = F)
}

#compute connectivity mat
conmat <- cor(t(ts), use = "pairwise.complete.obs") #[to do] - output warning if pairwise.complete.obs is needed

#write conmat to work
write.table(round(conmat,3), paste0(opt$work,'/',opt$subj,"_conmat.txt"), 
            row.names = F, 
            col.names = F,
            quote = F)

#output conmat heatmap to output
breaksList = seq(opt$lo, opt$up, by = 0.1)
color = colorRampPalette(rev(RColorBrewer::brewer.pal(n = 8, name = opt$colour)))(length(breaksList)) # Defines the vector of colors for the legend (it has to be of the same lenght of breaksList)

png(filename = paste0(opt$out,'/',opt$subj,"_conmat.png"))
pheatmap::pheatmap(conmat, treeheight_row = 0, treeheight_col = 0,
         main = opt$subj, cluster_rows=FALSE, cluster_cols=FALSE, breaks = breaksList, color = color) 
dev.off()


#output distribution (upper triangle)
dist <- as.data.frame(c(conmat[upper.tri(conmat, diag = F)]))
colnames(dist) <- "correlation"

dist <- ggplot(dist, aes(correlation)) + 
  geom_freqpoly(alpha = 0.5, bins = 30) + 
  ggtitle(paste(opt$subj, " - Distribution of values"))

ggsave(filename = paste0(opt$subj,"_dist.png"), 
         plot=dist, 
         device = "png",
         path=opt$out)




