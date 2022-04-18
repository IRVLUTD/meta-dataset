# set the required env vars
models=$1
gpu_ids=$2
perform_filtration_model=$3 #True/False for model
perform_filtration_ds=$4 #True/False for dataset
num_valid_episodes=$5
use_pretrained_backbone=$6
backbone=$7
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

source __set_suffix.sh $perform_filtration_model $num_valid_episodes $use_pretrained_backbone
source set_env.sh

for MODEL in $models
do
  name=${MODEL}_${SOURCE}${chkpt_suffix}${pretrained_phrase}-${backbone}
  
  if test "$backbone" = ""
  then
      name=${MODEL}_${SOURCE}${chkpt_suffix}${pretrained_phrase}
  fi
  
  export EXPNAME=$name
  echo $EXPNAME
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${EXPNAME} \
    --description=best_${EXPNAME}
done