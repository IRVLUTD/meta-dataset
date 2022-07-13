#!/bin/bash

# set the required env vars
cd ..; source set_env.sh; cd scripts

required_sets="TEST"
SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";

cd $SPLITS/splits;
rm tesla_splits.json; ln -s tesla-qualitative-results-in-the-real-world.json tesla_splits.json;
cd $ROOT_DIR;

# NOTE: make sure to take backup of existing $ROOT_DIR/records/ directory
timestamp=`date --rfc-3339=seconds`; timestamp=`echo ${timestamp// /_}`;
mv $RECORDS $RECORDS.bak.$timestamp

export DATASRC="$DATASET_DOWNLOAD_DIR/$UNCOMPRESSED_DATASET_DIR_NAME"

cd $DATASRC; rm test_data; ln -s test_data.gt.4.3.198-classes-without-query test_data; cd $ROOT_DIR;

python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=tesla --splits_root=$SPLITS --required_sets=$required_sets \
	--records_root=$RECORDS --tesla_data_root=$DATASRC \
	--image_filter_threshold=1 --do_support_set_oversampling=False

out_dir="$ROOT_DIR/records-4.3.test.real.198.classes"
rm -rf $out_dir
mv $RECORDS $out_dir