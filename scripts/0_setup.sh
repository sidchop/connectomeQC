#home, work folder setup
home=$PWD #default
while getopts :h: flag; do
    case "${flag}" in
        h) home=${OPTARG};; 
    esac
done



if [ ! -d $home/fmriqc ]; then
  mkdir $home/fmriqc
fi
export home=$home

if [ ! -d $home/fmriqc/work ]; then
  mkdir $home/fmriqc/work
fi

if [ ! -d $home/fmriqc/work/group ]; then
  mkdir $home/fmriqc/work/group
fi

if [ ! -d $home/fmriqc/output ]; then
  mkdir $home/fmriqc/output
fi


if [ ! -d $home/fmriqc/output/group ]; then
  mkdir $home/fmriqc/output/group
fi
