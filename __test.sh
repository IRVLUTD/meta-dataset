source __select_best_model.sh $1 $2 $3 $4 $5 $7 $8

# link dataset variant of choice, useful for tesla
export TESLA_DATASET_VARIANT=$6

backbone=$8
_backbone=$backbone
if test "$backbone" = "convnet"
then
    _backbone="four_layer_convnet"
fi

cd $RECORDS; rm tesla; ln -s $TESLA_DATASET_VARIANT tesla; cd $ROOT_DIR;

ls -l $RECORDS # useful to check if sym links are correct

for MODEL in $models
do
  export EXPNAME=${MODEL}_${SOURCE}
  for DATASET in tesla
  do
    echo "MODEL-FILTER: $perform_filtration_model"
    echo "DATASET-FILTER: $perform_filtration_ds"
    if test "$backbone" = "" # default backbone
    then
      # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
      export BESTNUM=$(grep best_update_num ${EXPROOT}/best_$EXPNAME.txt | awk '{print $2;}')
      python -m meta_dataset.train \
        --is_training=False \
        --records_root_dir=$RECORDS \
        --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${EXPNAME}'" \
        --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${EXPNAME}/model_${BESTNUM}.ckpt'" \
        --gin_bindings="Trainer.perform_filtration='${perform_filtration_ds}'" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Trainer.num_eval_episodes=600" \
        --gin_bindings="benchmark.eval_datasets='$DATASET'"
    else
      model="${EXPNAME}${chkpt_suffix}${pretrained_phrase}-${backbone}"
      # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
      export BESTNUM=$(grep best_update_num ${EXPROOT}/best_$model.txt | awk '{print $2;}')
      python -m meta_dataset.train \
        --is_training=False \
        --records_root_dir=$RECORDS \
        --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name=''" \
        --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${model}/model_${BESTNUM}.ckpt'" \
        --gin_bindings="Trainer.perform_filtration='${perform_filtration_ds}'" \
        --gin_bindings="Learner.embedding_fn = @${_backbone}" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Trainer.num_eval_episodes=600" \
        --gin_bindings="benchmark.eval_datasets='$DATASET'"      
    fi
  done
done
