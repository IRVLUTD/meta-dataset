models=$1
gpu_ids=$2
perform_filtration_model=$3

export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

source set_env.sh

for MODEL in $models
do
  exp_name=${MODEL}_${SOURCE}
  export EXPNAME=$exp_name

  if test "$perform_filtration_model" = "True"
  then 
    exp_name="${exp_name}-filtered"
  fi

  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${EXPNAME} \
    --description=best_${EXPNAME}
  # set BESTNUM to the "best_update_num" field in the corresponding best_....txt
  export BESTNUM=$(grep best_update_num ${EXPROOT}/best_${EXPNAME}.txt | awk '{print $2;}')

  for tesla_dataset_variant in tesla-mixture tesla-unseen tesla-seen tesla-synthetic-unseen-13
  do
    DATASET="tesla"
    export TESLA_DATASET_VARIANT=$tesla_dataset_variant
    cd $RECORDS; rm $DATASET; ln -s $TESLA_DATASET_VARIANT $DATASET; cd $ROOT_DIR;
    ls -l $RECORDS # useful to check if sym links are correct

    # For each trained model it is possible test on w/wo filtered tesla variants
    for perform_filtration_ds in False True
    do
      python -m meta_dataset.train \
        --is_training=False \
        --records_root_dir=$RECORDS \
        --summary_dir=${EXPROOT}/summaries/${EXPNAME}_eval_$DATASET \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${exp_name}'" \
        --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${exp_name}/model_${BESTNUM}.ckpt'" \
        --gin_bindings="benchmark.eval_datasets='$DATASET'" \
        --gin_bindings="Trainer.perform_filtration=${perform_filtration_ds}" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Trainer.num_eval_episodes=600"
    done
  done
done

# set the tesla symbolic link to tesla-unseen, reset to default
source set_env.sh
cd $RECORDS; rm tesla; ln -s tesla-unseen tesla; cd $ROOT_DIR;

# To check whether symbolic link points to tesla-unseen
ls -l $RECORDS
