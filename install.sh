!#/bin/bash
# Install useful libraries
sudo apt-get install gcc python-dev python-setuptools libffi-dev;
# Create an environment
conda create --name 3d-obj-det-fsl;
# Load the environment
conda activate 3d-obj-det-fsl;
# Install required packages
pip install -r requirements.txt;

# Set required env vars
export ROOT_DIR=$PWD;
export DATASRC="$ROOT_DIR/data";
export RECORDS="$ROOT_DIR/records";
# https://github.com/jishnujayakumar/meta-dataset#downloading-and-converting-datasets
export SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";

# Dataset download and conversion
mkdir -p $DATASRC $RECORDS;

# ilsvrc_2012 (left)
# https://github.com/jishnujayakumar/meta-dataset/blob/main/doc/dataset_conversion.md#ilsvrc_2012
mkdir -p $DATASRC/ILSVRC2012_img_train;
wget https://image-net.org/data/ILSVRC/2012/ILSVRC2012_img_train.tar;
tar -xvf ILSVRC2012_img_train.tar --directory ./ILSVRC2012_img_train;

cd ILSVRC2012_img_train;
for FILE in *.tar;
do
  mkdir ${FILE/.tar/};
  cd ${FILE/.tar/};
  tar xvf ../$FILE;
  cd ..;
done

wget http://www.image-net.org/data/wordnet.is_a.txt;
wget http://www.image-net.org/data/words.txt;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=ilsvrc_2012 \
  --ilsvrc_2012_data_root=$DATASRC/ILSVRC2012_img_train \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

# Omniglot
# https://github.com/jishnujayakumar/meta-dataset/blob/main/doc/dataset_conversion.md#omniglot
wget https://github.com/brendenlake/omniglot/raw/master/python/images_background.zip;
wget wget https://github.com/brendenlake/omniglot/raw/master/python/images_evaluation.zip;
mkdir -p omniglot;
unzip images_*.zip -d omniglot/;
zip omniglot-dataset.zip images_*.zip;
rm images_*.zip;

# conversion
cd omniglot/;
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=omniglot \
  --omniglot_data_root=$DATASRC/omniglot \
  --splits_root=$SPLITS \  --records_root=$RECORDS;

# aircraft
wget http://www.robots.ox.ac.uk/~vgg/data/fgvc-aircraft/archives/fgvc-aircraft-2013b.tar.gz;
tar -xzvf fgvc-aircraft-2013b.tar.gz;

# conversion
cd fgvc-aircraft-2013b;
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=aircraft \
  --aircraft_data_root=$DATASRC/fgvc-aircraft-2013b \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;
rm -rf fgvc-aircraft-2013b/;

# cu_birds (left)
gdown --id 1hbzc_P1FuxMkcabkgn9ZKinBwW683j45;
tar -xzvf CUB_200_2011.tgz;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=cu_birds \
  --cu_birds_data_root=$DATASRC/CUB_200_2011 \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

rm -rf CUB_200_2011/;


# dtd
wget https://www.robots.ox.ac.uk/~vgg/data/dtd/download/dtd-r1.0.1.tar.gz;
tar -xvzf dtd-r1.0.1.tar.gz;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=dtd \
  --dtd_data_root=$DATASRC/dtd \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

rm -rf dtd/;


# quickdraw (left)
mkdir -p $DATASRC/quickdraw;
gsutil -m cp "gs://quickdraw_dataset/full/numpy_bitmap/*.npy" $DATASRC/quickdraw;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=quickdraw \
  --quickdraw_data_root=$DATASRC/quickdraw \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

# fungi (left)
wget https://labs.gbif.org/fgvcx/2018/fungi_train_val.tgz;
wget https://labs.gbif.org/fgvcx/2018/train_val_annotations.tgz;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=fungi \
  --fungi_data_root=$DATASRC/fungi \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

rm -rf fungi/;

# vgg_flower (left -> error)
wget http://www.robots.ox.ac.uk/~vgg/data/flowers/102/102flowers.tgz;
wget http://www.robots.ox.ac.uk/~vgg/data/flowers/102/imagelabels.mat;

mkdir -p $DATASRC/vgg_flower;
tar -xzvf 102flowers.tgz -C ./vgg_flower;

python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=vgg_flower \
  --vgg_flower_data_root=$DATASRC/vgg_flower \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

zip vgg_flower.zip 102flowers.tgz imagelabels.mat;
rm 102flowers.tgz imagelabels.mat;


# traffic_sign (left -> error)
wget https://sid.erda.dk/public/archives/daaeac0d7ce1152aea9b61d9f1e19370/GTSRB_Final_Training_Images.zip;
unzip GTSRB_Final_Training_Images.zip;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=traffic_sign \
  --traffic_sign_data_root=$DATASRC/GTSRB \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

rm -rf GTSRB/;

# mscoco
mkdir -p $DATASRC/mscoco/;
cd $DATASRC/mscoco/;
wget http://images.cocodataset.org/zips/train2017.zip;
wget http://images.cocodataset.org/annotations/annotations_trainval2017.zip;
unzip train2017.zip && unzip annotations_trainval2017.zip;
cp annotations/instances_train2017.json .;

# conversion
python -m meta_dataset.dataset_conversion.convert_datasets_to_records \
  --dataset=mscoco \
  --mscoco_data_root=$DATASRC/mscoco \
  --splits_root=$SPLITS \
  --records_root=$RECORDS;

rm -rf train2017/ annotations/ instances_train2017.json;
cd .. && zip mscoco.zip train2017.zip annotations_trainval2017.zip;
