while getopts 'h:s:w:o:t:' flag; do
    case "${flag}" in
        h) home=${OPTARG};;  #home dir
        s) subj=${OPTARG};; #subj id
        w) workpath=${OPTARG};; # path to workdir
        o) outpath=${OPTARG} ;; 
        t) template=${OPTARG};; #.Rmd template
    esac
done

cp $template $outpath
mv $outpath/individual_template.Rmd $outpath/${subj}.Rmd 
Rscript scripts/render_individual_template.R  -s $subj -r  $outpath/${subj}.Rmd 
mv $outpath/${subj}.Rmd $workpath