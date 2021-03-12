#master file in r
library(optparse)

option_list = list(
  make_option(c("-h", "--home"), type="character", default=getwd(), 
              help='path to home/project directory'),
  make_option(c("-f", "--fmri"), type="character", default=NULL, 
              help="[Required] file with list of fmri scans. Can input multiple files, seperated 
              by a comma, e.g. 'fmri_list1.txt, fmri_list2.txt', files must have same number of scans 
              and be in the same order as a -s/--subj file."),
  make_option(c("-d", "--fd"), type="character", default=NULL,
              help="[Required] Path to fd file."),
  make_option(c("-a", "--atlas"), type="character", default=NULL, 
              help="[Required] Path to atlas"),
  make_option(c("-s", "--subj"), type="character", default=NULL, 
              help='[Recommended] subj ID, e.g. "sub-015c, or list of subj IDs, e.g. subj_list.txt"'),
  make_option(c("-t", "--indv_template"), type="character", default="scripts/individual_template.Rmd", 
              help='[Optional] path to tempate folder')
); 

opt_parser = OptionParser(option_list=option_list, add_help_option=FALSE);
opt = parse_args(opt_parser);

  #test
#----
opt$home <- "~/Dropbox/Sid/R_files/fmri_qc"
opt$fmri <- "test_data/scan_list.txt"
opt$fd <- "test_data/fd_list.txt"
opt$atlas <- "test_data/Schaefer2018_300Parcels_7Networks_order_FSLMNI152_2mm.nii"
opt$subj <-  "test_data/subjlist.txt"
#---



if (is.null(opt$fmri) | is.null(opt$atlas) | is.null(opt$fd) | is.null(opt$subj)){
  print_help(opt_parser)
  stop("Add error message", call.=FALSE)
}

setwd(paste0(opt$home)) 

fmri_list <- read.table(opt$fmri)
fd_list <- read.table(opt$fd)
subj_list <- read.table(opt$subj)

fmri_list <- read.table("test_data/scan_list.txt")
fd_list <- read.table("test_data/fd_list.txt")
subj_list <- read.table("test_data/subjlist.txt")
opt$atlas <- "test_data/Schaefer2018_300Parcels_7Networks_order_FSLMNI152_2mm.nii"

system("export LC_ALL=C")
#run 0_setup.s
system(paste0("bash scripts/0_setup.sh -h ", opt$home))

for (s in 1:dim(fmri_list)[1]) {
  out <- paste0(opt$home,"/fmriqc/output/",subj_list[s,],"/")
  work <- paste0(opt$home,"/fmriqc/work/",subj_list[s,],"/") 
  
  #subj setup
   system(paste0("bash scripts/1_subj_setup.sh -s ",subj_list[s,],
                 " -h ", opt$home,
                 " -f ", fmri_list[s,],
                 " -a ", opt$atlas ,
                 " -o ", work))
  
   #extract ts
   system(paste0("Rscript scripts/nii_roi2ts.R -i ", fmri_list[s,],
                 " -r ", opt$atlas,
                 " -w ", work,
                 " -s ", subj_list[s,]))
   
   
  #carpet plot
  system(paste0("Rscript scripts/2_carpetplotR.R -f ",fmri_list[s,],
                " -d ", 8 ,
                ' -r "random, gs" ',
                " -o ",out,"/",subj_list[s,]))
  
  #conmat
  system(paste0("Rscript scripts/3_make_conmat.R -t ", work, subj_list[s,],"_ts.txt", 
                " -o ", out ,
                " -w ", work, 
                " -s ", subj_list[s,],
                " -u  ", 1 ,
                " -l " , -1 ,
                " -c ","RdBu",
                " -m ", "True"))
  
  
  #FD
  system(paste0("Rscript scripts/4_compute_fd.R -f ", fd_list[s,],
                " -s ", subj_list[s,],
                " -o ", out ,
                " -l " ,.5,
                " -t ", .25 ,
                " -p ", .2,
                " -k ", 5))
  
  #make overlay
  system(paste0("Rscript scripts/5_make_overlay_png.R -f ", fmri_list[s,],
                " -a " , opt$atlas ,
                " -s ", subj_list[s,],
                " -o ", out,
                " -w ", work,
                " -g ", 5))
  
  
  system(paste0("bash scripts/6_execute_individual_render.sh -h ", opt$home ,
                " -s ", subj_list[s,],
                " -w ", work ,
                " -o ", out ,
                " -t ", opt$indv_template))
  
  message(paste0("Completed individual report for ", subj_list[s,]))
}
message("===================")
message("Making group report.")
message("===================")


system(paste0("Rscript scripts/7group_compute_fd_table.R"))

system(paste0("Rscript scripts/8group_compute_ROI_exclude.R"))

system(paste0("Rscript scripts/9group_FD_FC.R"))

system(paste0("Rscript scripts/10group_extract_centroids.R -a ",opt$atlas))

system(paste0("Rscript scripts/11group_FD_FC_distance.R"))

system(paste0("Rscript scripts/12group_subject2subject_fc.R -s ",opt$subj))



#Rscript scripts/master.R -h $PWD -f test_data/scan_list.txt -d test_data/fd_list.txt -a test_data/Schaefer2018_300Parcels_7Networks_order_FSLMNI152_2mm.nii -s test_data/subjlist.txt -t scripts/individual_template.Rmd 

