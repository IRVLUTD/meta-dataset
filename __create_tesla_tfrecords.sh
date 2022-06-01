#!/bin/bash

# set the required env vars
source set_env.sh

oversample_support_set=$1
image_filter_threshold=15
DATASET_DIR_NAMES=("tesla-mixture" "tesla-unseen" "tesla-seen" "tesla-synthetic-unseen-13")
end=4

if [ "$oversample_support_set" == "False" ];
then
   RECORDS="${RECORDS}-non-oversampled"
   end=3
   image_filter_threshold=1
fi

_RECORDS=${RECORDS}

for DATASET_DIR_NAME in ${DATASET_DIR_NAMES[@]:0:$end};
do
export DATASRC="$DATASET_DOWNLOAD_DIR/$DATASET_DIR_NAME"
 # For creating tfrecords of different tesla variants
 # If no variants then comment the following line
_RECORDS="$RECORDS/$DATASET_DIR_NAME"
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=tesla --splits_root=$SPLITS \
	--records_root=$_RECORDS --tesla_data_root=$DATASRC \
	--image_filter_threshold=$image_filter_threshold \
	--do_support_set_oversampling=$oversample_support_set
done