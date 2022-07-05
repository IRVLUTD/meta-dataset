cd ..; source set_env.sh; cd scripts

python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=ilsvrc_2012 \
  --ilsvrc_2012_data_root=$IMAGENET_DATASET_DIR \
  --splits_root=$SPLITS \
  --records_root=$RECORDS