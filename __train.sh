# set the required env vars
source set_env.sh
models=$1
gpu_ids=$2
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

for MODEL in $models 
do
    export EXPNAME=${MODEL}_${SOURCE}
    python -m meta_dataset.train \
    --records_root_dir=$RECORDS \
    --train_checkpoint_dir=${EXPROOT}/checkpoints/${DATASET_DIR_NAME}-${EXPNAME} \
    --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
    --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
    --gin_bindings="Trainer.experiment_name='$EXPNAME'" \
    --gin_bindings="Trainer.batch_size=$BS" \
    --gin_bindings="Trainer.checkpoint_to_restore=''" \
    --gin_bindings="Trainer.pretrained_source='scratch'"
done
