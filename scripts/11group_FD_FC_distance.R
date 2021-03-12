#Calculate FD-FC distance correlation

library(optparse)
library(ggplot2)
library(bio3d)

option_list = list(
  make_option(c("-c", "--cog"), type="character", default=paste0(getwd(),'/fmriqc/work/group/atlas_centroids.txt'), 
              help='atlas centrioid file (.txt)'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/output'), 
              help='Path to output folder'),
  make_option(c("-f", "--fdfc"), type="character", default=paste0(getwd(),'/fmriqc/work/group/FD_FC_matrix.txt'), 
              help='Path to output folder')
); 


opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
dist <- read.table(opt$cog, header = F) #load centroid coords
xyz.dist <- dist.xyz(dist)  #calculate euclidian distance between each pair of centroids
distance <- xyz.dist[upper.tri(xyz.dist)]
fc_fd <- read.table(opt$fdfc, header = F)
fc_fd <- fc_fd[upper.tri(fc_fd)] 
xy <- cbind(distance,fc_fd)

message('Making FC-FC distance plots')
ggplot(as.data.frame(xy), aes(x=distance, y=fc_fd)) + 
  geom_point(alpha=0.3)+
#  ggtitle("fix_gsr") + 
  stat_summary_bin(fun="mean", bins=20,
                   color='orange', size=2, geom='point') +
  stat_summary_bin(fun.data = mean_sdl, bins=20,
                   color='orange', size=0.5) + ylim(-1,1)

ggsave(filename = paste0(opt$out,'/group/FD_FC_dist.png'), 
       device = "png",
       width = 7, 
       height = 5)


           