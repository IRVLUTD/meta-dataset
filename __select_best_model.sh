# set the required env vars
source set_env.sh
models=$1
gpu_ids=$2
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

for MODEL in $models
do
  export EXPNAME=${MODEL}_${SOURCE}
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${EXPNAME} \
    --description=best_${EXPNAME}
done