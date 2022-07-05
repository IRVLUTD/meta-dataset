#!/bin/bash

# set the required env vars
source set_env.sh

required_sets="TRAIN,VALID"
SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";

cd $SPLITS/splits;
rm tesla_splits.json; ln -s tesla_splits.4.3.train.sim+real.323-classes.json tesla_splits.json;
cd $ROOT_DIR;

# NOTE: make sure to take backup of existing $ROOT_DIR/records/ directory
timestamp=`date --rfc-3339=seconds`; timestamp=`echo ${timestamp// /_}`;
mv $RECORDS $RECORDS.bak.$timestamp

export DATASRC="$DATASET_DOWNLOAD_DIR/$UNCOMPRESSED_DATASET_DIR_NAME"

cd $DATASRC; rm training_data; ln -s training_data.4.3.sim+real training_data; cd $ROOT_DIR;

python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=tesla --splits_root=$SPLITS --required_sets=$required_sets \
	--records_root=$RECORDS --tesla_data_root=$DATASRC \
	--image_filter_threshold=15 --do_support_set_oversampling=True

out_dir="$ROOT_DIR/records-4.3.train.sim+real.323.classes"
rm -rf $out_dir
mv $RECORDS $out_dir