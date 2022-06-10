### TODO: Give a suitable title
- This a forked repository of [Meta-Dataset](https://github.com/google-research/meta-dataset/). (Commit: [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5))
- Full documentation can be found [here](README-original.md).

### Before starting
  - Be sure to set the env variables in [set_env.sh](set_env.sh) and [usr.env](usr.env).
  - Set respective dataset names in [all_datasets.gin](meta_dataset/learn/gin/setups/all_datasets.gin).
  - **NOTE**: Any gin parameter initialized via the script files starting with "__" will override them. Please be careful about the parameters initialized via script files. Use the mandatory ones in scripts and keep the rest inside respective gin configs.

### Setup
```bash
# clone and cd
git clone https://github.com/IRVLUTD/meta-dataset.git; cd meta-dataset;

# If you want to use docker, open docker container in interactive mode
docker run \
-it --rm --runtime=nvidia \
-v <cloned-meta-dataset-dir-path>:/workspace --workdir=/workspace \
--name meta-dataset -e NVIDIA_VISIBLE_DEVICES=<list-of-gpu-ids> \
nvcr.io/nvidia/tensorflow:21.12-tf2-py3 # tensorflow 2

# run inside docker
apt-get update; apt install python3-tk pkg-config libcairo2-dev python-gi python-gi-cairo python3-gi python3-gi-cairo gir1.2-gtk-3.0;

# install dependencies
pip install -r requirements.txt
python setup.py install

# In order to use data.read_episodes module, task_adaptation code is required
# as per https://github.com/google-research/meta-dataset#adding-task_adaptation-code-to-the-path
git clone https://github.com/google-research/task_adaptation.git
cd task_adaptation; python setup.py install; cd ..; 
export PYTHONPATH=$PYTHONPATH:$PWD
```

- For testing any dataset, set perform_filtration=True/False in (trainer_config.gin)[meta_dataset/learn/gin/setups/trainer_config.gin]
### To run experiments with tesla dataset, following commands can be used
```bash
# TODO: remove/archive install.sh before paper submission
# bugs exist in the script, needs debugging
# hence download only required datasets
# recommended: imagenet only
# bash install.sh

# set required env variables
# change as per your need
source set_env.sh

# Download the TESLA dataset
# NOTE: make sure that the download directory
# has ample amount of disk space as the following
# 2 steps after download will also need additional space

# move to DATASET_DOWNLOAD_DIR
cd $DATASET_DOWNLOAD_DIR

# download dataset
wget $DATASET_URL

# uncompress to TESLA directory: this might take a while
7za x FSL-Sim2Real-IRVL-2022.7z -o$DATASET_DOWNLOAD_DIR/$UNCOMPRESSED_DATASET_DIR_NAME

# replace " " in class names with "_"
cd $UNCOMPRESSED_DATASET_DIR_NAME
for data in training_data test_data
do
  cd $data; for file in *; do mv "$file" `echo $file | tr ' ' '_'` ; done; cd ..
done

# rename m&m's package class in test_set
mv m\&m\'s_package/ $(echo "m\&m\'s_package/" | sed -e 's/[^A-Za-z0-9._-]//g')
# rename m&m's package class in test_set
mv rubik\'s_cube/ $(echo "rubik\'s_cube" | sed -e 's/[^A-Za-z0-9._-]//g')

# move back to meta-dataset root
cd $ROOT_DIR

# filter variant classes to represent mixture(52), unseen(41), seen(11)
python __select_and_create_test_classes_for_variants.py

# create tfrecords
bash __create_tesla_tfrecords.sh <boolean-to-oversample-support-set-images> <required-sets>
# for <required-sets> use CAPITAL LETTER and don't use spaces
# E.g. bash __create_tesla_tfrecords.sh True/False "TRAIN,VALID,TEST"

# get best from arxiv_v2_dev
cd meta_dataset/learn/gin
svn checkout https://github.com/google-research/meta-dataset/branches/arxiv_v2_dev/meta_dataset/learn/gin/best
cd best
sed -i 's/models/learners/g' *
ln -s best best_v2
cd $ROOT_DIR

# reproduce the results
# TODO: should be removed before paper submission
# trained on prototypical/matching networks
# bash reproduce_best_results.sh

# create imagenet tfrecords for backbone pretraining
bash __create_imagenet_tfrecords_for_pretraining_backbones.sh

# pretrain-baseline
bash __baseline_and_pretraining_on_imagenet.sh  <models> <gpu-ids> <resnet34-max-stride>
# e.g. bash __baseline_and_pretraining_on_imagenet.sh  "resnet mamlconvnet mamlresnet" "0"  "4/8/16/32/None"

# select best pre-trained backbones
bash __select_best_pretrained_backbone_models.sh

# Train TESLA; For other md-datasets, always set <perform-filtration-flag> as False
bash __train.sh \
<models> \
<gpu-ids> \
<perform-filtration-flag> \
<num-validation-episodes> \
<use-pretrained-backbone or _>
<backbone>
# e.g. bash __train.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" "True/False" use_pretrained_backbone resnet34/resnet_ctx/""

# To select and see the best model after training
# __test.sh does run __select_best_model.sh
# hence use this just to see the best model specs
# For datasets other than TESLA, always set <perform-filtration-flag> as False
# bash __select_best_model.sh <models> <gpu-ids>  <perform-filtration-flag-for-model> _ <num-valid-episodes> <use_pretrained_backbone or _> <backbone> #uncomment this
# e.g. bash __select_best_model.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" "True/False" _ 60 use_pretrained_backbone resnet34/resnet_ctx/""


# evaluate the trained models
# tested on prototypical/matching networks
# For datasets other than TESLA, always set 
# <perform-filtration-flag-for-model> and <perform-filtration-flag-for-model> as False
bash __test.sh <models> \
<gpu-ids> \
<perform-filtration-flag-for-model> \
<perform-filtration-flag-for-dataset> \
<num-validation-episodes> \
<tesla-dataset-variant> \
<use-pretrained-backbone or _>
<backbone>
# e.g. bash __test.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" "True/False" "True/False" 60 "tesla-mixture" use_pretrained_backbone resnet/""

# To test on all tesla variants
bash __test_on_all_tesla_variants.sh \
<model> \
<gpu_id> \
<perform_filtration-flag> \
<num-validation-episodes>
<use-pretrained-backbone or _>
<backbone>
# e.g. bash __test_on_all_tesla_variants.sh "maml" 0 False 60

# get test results from logs
bash __logs_filter.sh

# for testing joint segmentation; NOTE: link the appropriate tfrecords dir to records-non-oversampled before running
bash __test_joint_segmentation.sh \
<model> <gpu-id> <clean or cluttered-training> \
<tesla-variant> <bestnum> 
# e.g.bash __test_joint_segmentation.sh crosstransformer 1 True tesla-seen 51000

# create real test data
python create_test_data_for_4.3.real.py <absolute-path>
```

### To run experiments with other datasets
#### NOTE: 
  - Set DATASET_DIR_NAME to predefined dataset alias (E.g. omniglot, fungi) from Meta-Dataset in [usr.env](usr.env).
    - The only variables that need to be changed are DATASET_DIR_NAME and BS (as per user's need).
  - Set respective dataset names in [all_datasets.gin](meta_dataset/learn/gin/setups/all_datasets.gin). 
  - Run the following commands after dataset download and conversion. Refer [this](doc/dataset_conversion.md) for more details.
```bash
# For other md-datasets, always set <perform-filtration-flag> as False
bash __train.sh \
<models> \
<gpu-ids> \
False \
<num-validation-episodes> \
<use-pretrained-backbone or _>
<backbone>
bash __train.sh <models> <gpu-ids> False
# e.g. bash __train.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" False 60 use_pretrained_backbone resnet/""

# To select and see the best model after training
# __test.sh does run __select_best_model.sh
# hence use this just to see the best model specs
# bash __select_best_model.sh <models> <gpu-ids>  False _ <num-valid-episodes> <use-pretrained-backbone or _> <backbone> #uncomment this
# e.g. bash __select_best_model.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" False _ 60 use_pretrained_backbone resnet/""


# evaluate the trained models
# tested on prototypical/matching networks
bash __test.sh <models> <gpu-ids> False False <dataset-name> <use-pretrained-backbone or _> <backbone>
# e.g. bash __test.sh "baseline baselinefinetune matching prototypical maml maml_init_with_proto" "0" False False imagenet use_pretrained_backbone resnet/""
```
