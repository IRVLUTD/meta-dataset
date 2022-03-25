# NOTE: DATASET_DOWNLOAD_DIR shouldn't have a "/" at the end

# export DATASET_DOWNLOAD_DIR=<absolute/path/to/store/downloaded/dataset>
# export UNCOMPRESSED_DATASET_DIR_NAME="TESLA"

export DATASET_DOWNLOAD_DIR="/home/jishnu/Desktop/"
export UNCOMPRESSED_DATASET_DIR_NAME="TESLA"

# TODO: populate after publication
# export DATASET_URL=<dataset-url>

export CUDA_VISIBLE_DEVICES="0";
export BS=1;
export ROOT_DIR=$PWD;
export DATASRC="$ROOT_DIR/datasets";
export RECORDS="$ROOT_DIR/records";
export SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";
export EXPROOT="$ROOT_DIR/experiment_output";
#export EXPROOT="$ROOT_DIR/experiment_output.delete";

# append to .env file to recover the info
# if environment variables are lost
echo "DATASET_DOWNLOAD_DIR=$DATASET_DOWNLOAD_DIR" > .env
echo "UNCOMPRESSED_DATASET_DIR_NAME=$UNCOMPRESSED_DATASET_DIR_NAME" >> .env
