source set_env.sh
source evaluate.sh
export SOURCE=all
# for MODEL in baseline baselinefinetune matching prototypical maml maml_init_with_proto
for MODEL in matching prototypical
do
  export EXPNAME=${MODEL}_${SOURCE}
  # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
  export BESTNUM=$(grep best_update_num ${EXPROOT}/best_${EXPNAME}.txt | awk '{print $2;}')
  for DATASET in tesla
  do
    python -m meta_dataset.train \
      --is_training=False \
      --records_root_dir=$RECORDS \
      --summary_dir=${EXPROOT}/summaries/${EXPNAME}_eval_$DATASET \
      --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
      --gin_bindings="Trainer.experiment_name='${EXPNAME}'" \
      --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${EXPNAME}/model_${BESTNUM}.ckpt'" \
      --gin_bindings="benchmark.eval_datasets='$DATASET'"
  done
done