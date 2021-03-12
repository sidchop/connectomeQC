#ROIs with low signals

# make fc exclusion table
library(optparse)
option_list = list(
  make_option(c("-w", "--work"), type="character", default=paste0(getwd(),'/fmriqc/work'), 
              help='Path to work folder'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/output/group'), 
              help='Path to work folder')
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser,);

row_mean_list <- list.files(path = opt$work, 
                      pattern = "*_rowmeans.txt", 
                      recursive = TRUE,
                      full.names = T)

#concat means
means <-   scan(row_mean_list[1])
for (s in 2:length(row_mean_list)) {
  temp <-   scan(row_mean_list[2])
  means <- cbind(means, temp)
}
roi_means <- as.data.frame(rowMeans(means))
roi_means[,2] <- c(1:dim(roi_means)[1])    #add a index to track the original ordering
roi_means <- roi_means[order(roi_means$`rowMeans(means)`, decreasing = T),]



#calculate pairwise diff
##caluclate pairwise difference (pwd)
pwd <- data.frame(matrix(ncol = 1, nrow = dim(roi_means)[1]-1)) 
x <- 1 
y <- 2
for (i in 1:dim(roi_means)[1]) {
  pwd[i,] <- roi_means[x,1] - roi_means[y,1]
  x <- x + 1
  y <- y + 1
}


largest_pwd <- which.max(abs(na.omit(unlist(pwd))))
elbow <- roi_means[largest_pwd, 2]
##Visalise elbow

png(filename = paste0(opt$out,'/low_singal_ROIs_bp.png'))
boxplot(roi_means[1]) 
abline(h=roi_means[largest_pwd, 1], col="red", lty=2, lwd =2) 
dev.off()

low_signal_rois <- as.integer(row.names(which(roi_means[1]<roi_means[largest_pwd, 1], arr.ind = T)))
write.table(low_signal_rois, paste0(opt$out,'/low_singal_ROIs.txt'),
            col.names = F, quote = F, row.names = F)








# To do: add a png of nifti with low signal ROIs highlighted
#atlas <- neurobase::readNIfTI2("test_data/Schaefer2018_300Parcels_7Networks_order_FSLMNI152_2mm.nii")
##mask atlas with low_sigal ROIs
#dims = dim(atlas)
#arr = array(rnorm(prod(dims)), dim = dims)
#nim = oro.nifti::nifti(arr)
#mask = atlas == low_singnal_rois
#
#masked = neurobase::mask_img(atlas, mask)
#atlas[atlas==c(low_singnal_rois)] 
#oro.nifti::orthographic(atlas)
#neurobase::cog(atlas)
