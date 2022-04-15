models=$1
gpu_ids=$2
perform_filtration=$3

export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

for model in $models
do  
    ROOT_DIR=$PWD
    RECORDS="$ROOT_DIR/records"
    EXPROOT="$ROOT_DIR/experiment_output/tesla-unseen";
    export EXPNAME="${model}_${SOURCE}"

    python -m meta_dataset.analysis.select_best_model \
        --all_experiments_root=$EXPROOT \
        --experiment_dir_basenames='' \
        --restrict_to_variants=${EXPNAME} \
        --description=best_${EXPNAME}

    # for tesla_dataset_variant in tesla-mixture tesla-unseen tesla-seen tesla-synthetic-unseen-13
    for tesla_dataset_variant in tesla-seen tesla-synthetic-unseen-13
    do
        export TESLA_DATASET_VARIANT=$tesla_dataset_variant
        export BESTNUM=$(grep best_update_num ${EXPROOT}/best_${EXPNAME}.txt | awk '{print $2;}')
        # For each trained model it is possible test on w/wo filtered tesla variants
        for perform_filtration_ds in False True
        # for perform_filtration_ds in False #True
        do
            python -m meta_dataset.train \
            --is_training=False \
            --records_root_dir=$RECORDS \
            --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
            --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
            --gin_bindings="Trainer.experiment_name='${EXPNAME}'" \
            --gin_bindings="Trainer.checkpoint_to_restore='${EXPROOT}/checkpoints/${EXPNAME}/model_${BESTNUM}.ckpt'" \
            --gin_bindings="Trainer.perform_filtration='${perform_filtration_ds}'" \
            --gin_bindings="Trainer.num_eval_episodes=600" \
            --gin_bindings="benchmark.eval_datasets='tesla'"
            # --gin_bindings="DataConfig.image_height=126"  
        done
    done
done

# set the tesla symbolic link to tesla-unseen, reset to default
source set_env.sh
cd $RECORDS; rm tesla; ln -s tesla-unseen tesla; cd $ROOT_DIR;

# To check whether symbolic link points to tesla-unseen
ls -l $RECORDS
