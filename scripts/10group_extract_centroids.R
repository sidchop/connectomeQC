#compute fd fc dist
#compute centroids 
library(optparse)
option_list = list(
  make_option(c("-a", "--atlas"), type="character", default=NULL, 
              help='Path to atlas'),
  make_option(c("-o", "--out"), type="character", default=paste0(getwd(),'/fmriqc/work/group'), 
              help='Path to work folder')
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

atlas <- neurobase::readNIfTI2(opt$atlas)

message('Calulating center of gravity (COG) for each ROI in the atlas image.')
#get voxel coordinates
cog <- matrix(nrow=length(unique(atlas[atlas>0])), ncol = 3)
for (s in 1:length(unique(atlas[atlas>0]))){
  temp <- atlas
  temp[temp!=s] <- NA
  cog[s,] <-  neurobase::cog(temp,)
}
#vox to MNI
for (c in 1:dim(cog)[1]){
cog[c,] <- oro.nifti::translateCoordinate(cog[c,],nim=atlas)
}
cog <- round(cog, 0)
write.table(cog, paste0(opt$out,'/atlas_centroids.txt'),
            col.names = F, quote = F, row.names = F)


