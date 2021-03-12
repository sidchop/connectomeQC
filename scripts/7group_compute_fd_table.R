# make fc exclusion table
library(optparse)
option_list = list(
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/output'), 
              help='Path to output  folder')
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


fd_list <- list.files(path = opt$out, 
                      pattern = "*_fd_metrics.txt", 
                      recursive = TRUE,
                      full.names = T)
                      
#merge fd files
table <-   read.table(fd_list[1])
for (s in 2:length(fd_list)) {
temp  <-   read.table(fd_list[s])
table <- rbind(table, temp)
}


write.table(table, paste0(opt$out,'/group/group',"fd_metrics.txt"), quote = F)
