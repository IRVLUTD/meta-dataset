# TODO: Uncomment this when final git push would be done before paper submission
# export DATASET_DOWNLOAD_DIR=<absolute/path/to/store/downloaded/dataset> # NOTE: DATASET_DOWNLOAD_DIR shouldn't have a "/" at the end
# export UNCOMPRESSED_DATASET_DIR_NAME="TESLA"

# TODO: REMOVE this after all experiments
export DATASET_DOWNLOAD_DIR="/home/jishnu/Desktop" # NOTE: DATASET_DOWNLOAD_DIR shouldn't have a "/" at the end
export UNCOMPRESSED_DATASET_DIR_NAME="tesla-mixture"

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
echo "CUDA_VISIBLE_DEVICES"=$CUDA_VISIBLE_DEVICES >> .env
echo "BS"=$BS >> .env
echo "ROOT_DIR"=$ROOT_DIR >> .env
echo "DATASRC"=$DATASRC >> .env
echo "RECORDS"=$RECORDS >> .env
echo "SPLITS"=$SPLITS >> .env
echo "EXPROOT"=$EXPROOT >> .env
