#make QC-FC plot and mean conmat
library(optparse)
option_list = list(
  make_option(c("-w", "--work"), type="character", default=paste0(getwd(),'/fmriqc/work'), 
              help='Path to work folder'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/output'), 
              help='Path to work folder'),
  make_option(c("-u", "--up"), type="double", default=.8, 
              help='Upper limit on colour bar [Default: .8]'),
  make_option(c("-l", "--lo"), type="double", default=-.8, 
              help='lower limit on colour bar [Default: -.8]'),
  make_option(c("-c", "--colour"), type="character", default="RdBu", 
              help='Colour pallette, can be any brewer.pal. See https://rdrr.io/cran/RColorBrewer/man/ColorBrewer.html. [Default: "RdBu"]')
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

#read mean fd
mean_fd <- read.table(paste0(opt$out,'/group/groupfd_metrics.txt'))[1]

#read all conmats into 4D array
conmat_list <- list.files(path = opt$work, 
                      pattern = "*_conmat.txt", 
                      recursive = TRUE,
                      full.names = T)

parc <- length(read.table(conmat_list[1]))
all_conmat <- array(numeric(),dim = c(parc,parc, length(conmat_list)))
for (c in 1:length(conmat_list)){
  all_conmat[ , , c] <-  as.matrix(read.table(conmat_list[c]))
}

#print mean FC matrix png
mean_conmat <- apply(all_conmat, c(1,2), mean)

write.table(round(mean_conmat,3), paste0(opt$work,'/group/meanconmat.txt'), 
            row.names = F, 
            col.names = F,
            quote = F)

breaksList = seq(opt$lo, opt$up, by = 0.1)

color = colorRampPalette(rev(RColorBrewer::brewer.pal(n = 8, name = opt$colour)))(length(breaksList)) # Defines the vector of colors for the legend (it has to be of the same lenght of breaksList)

png(filename = paste0(opt$out,'/group/group_meanconmat.png'))
pheatmap::pheatmap(mean_conmat, treeheight_row = 0, treeheight_col = 0,
                   main = "Mean connectivity matrix", cluster_rows=FALSE, cluster_cols=FALSE, 
                   breaks = breaksList, color = color) 
dev.off()


#compute FC-FD
C <- array(numeric(),c(parc,parc))
for (e in 1:parc) { 
  for (i in 1:parc) {
    C[e, i] <- cor(all_conmat[e, i, ], mean_fd, use = "pairwise.complete.obs")
  }
}
C[is.na(C)] <- 0

#save FD-FC matrix
write.table(round(C,3), paste0(opt$work,'/group/FD_FC_matrix.txt'), 
            row.names = F, 
            col.names = F,
            quote = F)

#print FD-FC matrix png
library(RColorBrewer)
breaks = seq(-1,1, 0.1)
colours = colorRampPalette(c("navy", "white", "firebrick3"))(20)
png(filename = paste0(opt$out,'/group/FD_FC_mat.png'))
pheatmap::pheatmap(C, cluster_rows=FALSE, cluster_cols=FALSE,
                   main = "FC-FD", breaks = breaks,
                   color = colours)
dev.off()

#print FD-FC boxplot png
library(ggplot2)
fd_fc <- as.data.frame(c(C[upper.tri(C)]))

ggplot(data = fd_fc, aes(x="", y=`c(C[upper.tri(C)])`)) + 
  geom_boxplot() +
  ylab('FC-FD correlation') +
  ylim(-1,1) +
  ggtitle("FC-FD distribution")

ggsave(filename = paste0(opt$out,'/group/FD_FC.png'), 
       device = "png",
       width = 6, 
       height = 6)


