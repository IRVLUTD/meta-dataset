# set the required env vars
source set_env.sh
export BS=1;

# convert dataset to records
# python -m meta_dataset.dataset_conversion.convert_datasets_to_records   \
# --dataset=tesla --tesla_data_root=$DATASRC/TESLA --splits_root=$SPLITS \
# --records_root=$RECORDS

# start training 
export SOURCE=all
export MODEL=prototypical
export EXPNAME=${MODEL}_${SOURCE}
python -m meta_dataset.train \
--records_root_dir=$RECORDS \
--train_checkpoint_dir=${EXPROOT}/checkpoints/${EXPNAME} \
--summary_dir=${EXPROOT}/summaries/${EXPNAME} \
--gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
--gin_bindings="Trainer.experiment_name='$EXPNAME'" \
--gin_bindings="Trainer.batch_size=$BS" \
--gin_bindings="Trainer.checkpoint_to_restore=''" \
--gin_bindings="Trainer.pretrained_source='scratch'"
