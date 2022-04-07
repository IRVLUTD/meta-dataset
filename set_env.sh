source usr.env

# TODO: populate after publication
# DATASET_URL=<dataset-url>
ROOT_DIR=$PWD;
DATASRC="$DATASET_DOWNLOAD_DIR/$DATASET_DIR_NAME"; # Used for creating TESLA tfrecords only
RECORDS="$ROOT_DIR/records";
SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";
EXPROOT="$ROOT_DIR/experiment_output/${DATASET_DIR_NAME}${suffix}";

# append to .env file to recover the info
# if environment variables are lost
echo "BS"=$BS > .env
echo "SPLITS"=$SPLITS >> .env
echo "EXPROOT"=$EXPROOT >> .env
echo "DATASRC"=$DATASRC >> .env
echo "RECORDS"=$RECORDS >> .env
echo "ROOT_DIR"=$ROOT_DIR >> .env

# echo "DATASET_URL=$DATASET_URL" >> .env
echo "DATASET_DIR_NAME"=$DATASET_DIR_NAME >> .env
echo "DATASET_DOWNLOAD_DIR=$DATASET_DOWNLOAD_DIR" >> .env
echo "UNCOMPRESSED_DATASET_DIR_NAME=$UNCOMPRESSED_DATASET_DIR_NAME" >> .env
