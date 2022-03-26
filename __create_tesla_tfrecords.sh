#!/bin/bash

# set the required env vars
source set_env.sh
python -m meta_dataset.dataset_conversion.convert_datasets_to_records   \
	--dataset=tesla --splits_root=$SPLITS --records_root=$RECORDS \
	--tesla_data_root=$DATASRC