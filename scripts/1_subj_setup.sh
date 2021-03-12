#subject folder setup and extract ts

while getopts 'h:s:f:a:o:' flag; do
    case "${flag}" in
        h) home=${OPTARG};;  #home dir
        s) subj=${OPTARG};;  #subj id
        f) fmri=${OPTARG};;  # full fmri path
        a) atlas=${OPTARG};; # full atlas path
        o) outpath=${OPTARG};; # path to output time series
    esac
done
#home=$home

if [ ! -d $home/fmriqc/work/$subj ]; then
  mkdir $home/fmriqc/work/$subj
fi


if [ ! -d $home/fmriqc/output/$subj ]; then
  mkdir $home/fmriqc/output/$subj
fi
