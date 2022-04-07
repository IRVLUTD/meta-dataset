# set the required env vars
models=$1
gpu_ids=$2
perform_filtration_model=$3 #True/False for model
perform_filtration_ds=$4 #True/False for dataset
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

source __set_suffix.sh $perform_filtration_model
source set_env.sh

for MODEL in $models
do
  export EXPNAME=${MODEL}_${SOURCE}${chkpt_suffix}
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${EXPNAME} \
    --description=best_${EXPNAME}
done
