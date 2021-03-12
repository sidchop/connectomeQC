#subject to subject FC correlation plot 
library(optparse)
option_list = list(
  make_option(c("-w", "--work"), type="character", default=paste0(getwd(),'/fmriqc/work'), 
              help='Path to work folder'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/output'), 
              help='Path to work folder'),
  make_option(c("-s", "--subj"), type="character", default=NULL, 
              help='list of subj IDs, e.g. subj_list.txt"')
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
conmat_list <- list.files(path = opt$work, 
                          pattern = "*_conmat.txt", 
                          recursive = TRUE,
                          full.names = T)

conmat_list <- sort(conmat_list,decreasing = F)
parc <- length(read.table(conmat_list[1]))
all_conmat <- array(numeric(),dim = c(parc,parc, length(conmat_list)))
for (c in 1:length(conmat_list)){
  all_conmat[ , , c] <-  as.matrix(read.table(conmat_list[c]))
}

subj_list <- read.table(opt$subj, header = F)
subj_list[,1]  <- sort(subj_list[,1], decreasing = F)

y <- NULL
for (c in 1:length(conmat_list)) {
  x <-   all_conmat[ , , c][upper.tri(  all_conmat[ , , c], diag = F)]
  y <- cbind(y,x)
}
cor <- cor(y)
row.names(cor) <- colnames(cor) <-  subj_list[,1]
breaks = seq(0,1, 0.01)
png(filename = paste0(opt$out,'/group/subject2subject_fc_cor.png'))
pheatmap::pheatmap(cor, cluster_rows = F, 
                   cluster_cols = F, 
                   main = "subject-subject FC correlations",
                   breaks = breaks, angle_col = 45)

dev.off()
#Which subjects have a low correlation?
colmeans_cor <- colMeans(cor)
low_cor_subs <- which(abs(colmeans_cor) < .4)
if (length(low_cor_subs) != 0){write.table(names(low_cor_subs), 
                                           file = paste0(opt$out,'/group/low_cor_subs.txt'), quote = F,
                                           col.names = F, row.names = F)}

