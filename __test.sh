source __select_best_model.sh $1 $2 $3 $4 $5

# link dataset variant of choice, useful for tesla
export TESLA_DATASET_VARIANT=$6
cd $RECORDS; rm tesla; ln -s $TESLA_DATASET_VARIANT tesla; cd $ROOT_DIR;

ls -l $RECORDS # useful to check if sym links are correct

for MODEL in $models
do
  export EXPNAME=${MODEL}_${SOURCE}
  # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
  export BESTNUM=$(grep best_update_num ${EXPROOT}/best_${EXPNAME}${chkpt_suffix}.txt | awk '{print $2;}')
  for DATASET in tesla
  do
    echo "MODEL-FILTER: $perform_filtration_model"
    echo "DATASET-FILTER: $perform_filtration_ds"
    python -m meta_dataset.train \
      --is_training=False \
      --records_root_dir=$RECORDS \
      --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
      --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
      --gin_bindings="Trainer.experiment_name='${EXPNAME}'" \
      --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${EXPNAME}${chkpt_suffix}/model_${BESTNUM}.ckpt'" \
      --gin_bindings="Trainer.perform_filtration='${perform_filtration_ds}'" \
      --gin_bindings="Trainer.num_eval_episodes=600" \
      --gin_bindings="benchmark.eval_datasets='$DATASET'"
  done
done
