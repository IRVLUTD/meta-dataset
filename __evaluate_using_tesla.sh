# set the required env vars
source set_env.sh
models=$1
gpu_ids=$2
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

for MODEL in $models
do
  export EXPNAME=${MODEL}_${SOURCE}
  # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
  # export BESTNUM=$(grep best_update_num ${EXPROOT}/best_${EXPNAME}.txt | awk '{print $2;}')
  # for DATASET in ilsvrc_2012 omniglot aircraft cu_birds dtd quickdraw fungi vgg_flower traffic_sign mscoco
  for DATASET in tesla; 
  do
    python -m meta_dataset.train \
      --is_training=False \
      --records_root_dir=$RECORDS \
      --summary_dir=${EXPROOT}/summaries/${EXPNAME}_eval_$DATASET \
      --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
      --gin_bindings="Trainer.experiment_name='${EXPNAME}'" \
      --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${EXPNAME}/model_5500.ckpt'" \
      --gin_bindings="benchmark.eval_datasets='$DATASET'"
  done
done