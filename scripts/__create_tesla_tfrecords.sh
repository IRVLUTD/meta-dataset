#!/bin/bash

# set the required env vars
source set_env.sh

oversample_support_set=$1
required_sets=$2
image_filter_threshold=15
DATASET_DIR_NAMES=("tesla-mixture" "tesla-unseen" "tesla-seen" "tesla-synthetic-unseen-13")
end=4

if [ "$oversample_support_set" == "False" ]; # for 4.2
then
   RECORDS="${RECORDS}-non-oversampled"
   end=3
   image_filter_threshold=1
fi

_RECORDS=${RECORDS}

cd $SPLITS/splits;
rm tesla_splits.json; ln -s tesla_splits.4.1-2.json tesla_splits.json;
cd $ROOT_DIR;

for DATASET_DIR_NAME in ${DATASET_DIR_NAMES[@]:0:$end};
do
export DATASRC="$DATASET_DOWNLOAD_DIR/$DATASET_DIR_NAME"
 # For creating tfrecords of different tesla variants
 # If no variants then comment the following line
_RECORDS="$RECORDS/$DATASET_DIR_NAME"
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=tesla --splits_root=$SPLITS --required_sets=$required_sets \
	--records_root=$_RECORDS --tesla_data_root=$DATASRC \
	--image_filter_threshold=$image_filter_threshold \
	--do_support_set_oversampling=$oversample_support_set

out_dir="$_RECORDS/tesla"
mv $out_dir/* $_RECORDS; rmdir $out_dir
done