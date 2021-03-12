#calculate exclusion criteria inased on FD
library(optparse)
option_list = list(
  make_option(c("-f", "--fd"), type="character", default=NULL,
              help="[Required] Path to fd file."),
  make_option(c("-s", "--subj"), type="character", default="subj",
              help="[Optional], Subject id"),
  make_option(c("-l", "--lenient_mean"), type="double", default=.5, 
              help='Lenient meanFD exclusion criteria [Default = .5]'),
  make_option(c("-t", "--stringent_mean"), type="double", default=.25, 
              help='Stringent meanFD exclusion criteria [Default = .25]'),
  make_option(c("-p", "--stringent_percent"), type="double", default=.20, 
              help='Stringent, 20% percent of fd values > x [Default = .20]'),
  make_option(c("-k", "--stringent_largespike"), type="double", default=5, 
              help='Stringent, any fd value > x [Default = 5]'),
  make_option(c("-o", "--out"), type="character", default=getwd(), 
              help='[Optional] Directory to output  image')
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser,);

if (is.null(opt$fd)){
  print_help(opt_parser)
  stop("Atleast one argument must be supplied (-f, eg. -f fd.txt)", call.=FALSE)
}

fd <- read.table(opt$fd)
colnames(fd) <- "fd"
fd <- fd[!is.na(as.numeric(as.character(fd$fd))),] #make sure all numbers are numeric and remove strings
fd <- as.numeric(fd) 

mean <- round(mean(fd),3)

fd_metrics <- as.data.frame(t(c(mean, mean > opt$lenient_mean, 
                                mean > opt$stringent_mean, 
                                (sum(fd>opt$stringent_percent)/length(fd))>.20, 
                                any(fd>opt$stringent_largespike))))

row.names(fd_metrics) <- opt$subj

colnames(fd_metrics) <- c("mean_fd", "lenient_mean_exclude", "stringent_mean_exclude", 
                          "percent_exclude", "large_spike_exclude")

write.table(fd_metrics, paste0(opt$out,'/',opt$subj,"_fd_metrics.txt"), quote = F)



# optional [distribution of timeseries to FD]
#ts <- as.matrix(read.table(tspath, header = F))
#dim(ts)
#cor <- cor(fd, t(ts))
#hist(cor)


