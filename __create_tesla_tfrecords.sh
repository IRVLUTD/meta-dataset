#!/bin/bash
source set_env.sh
python -m meta_dataset.dataset_conversion.convert_datasets_to_records   \
	--dataset=tesla --tesla_data_root=$DATASET_DOWNLOAD_DIR/$UNCOMPRESSED_DATASET_DIR_NAME \
	--splits_root=$SPLITS --records_root=$RECORDS
