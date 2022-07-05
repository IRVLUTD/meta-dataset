# FewSOL
This is the code for our paper [FewSOL: A Dataset for Few-Shot Object Learning in Robotic Environments](https://irvlutd.github.io/FewSOL)[1].

TODO: ADD figures/segmentation.pdf as the jumbotron image from the paper (if needed). 

- The code is build upon [Meta-Dataset](https://github.com/google-research/meta-dataset/):[c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5)[*].In case of any query relating to this, please contact [Meta-Dataset](https://github.com/google-research/meta-dataset/)'s authors.
- Modifications have been made to [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5) in order to perform the following experiments. 
  - Few-Shot Classification (FSC) [Section: 4.1 in [1]]
  - Joint Object Segmentation and Few-Shot Classification (JOS-FCS) [Section: 4.2 in [1]]
  - Real world setting for JOS-FCS  [Section: 4.3 in [1]]

# Requirements
- Python >= 3.7.5, pip
- zip, unzip, 7z
- Docker (Recommended)
- Tensorflow

# Helpful pointers
- Docker Image: [nvcr.io/nvidia/tensorflow](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow)[2] can be used. Use the `21.12-tf1-py3` tag.
    - ```bash
      docker run --gpus all -id --rm -v <cloned-meta-dataset-dir-path>:/workspace --workdir=/workspace --name fewsol nvcr.io/nvidia/tensorflow:21.12-tf1-py3
      ```
    - TODO: Link setup Setup the environment using instructions in [Setup](#setup) 
- Alternatively, Docker Image: [irvlutd/meta-datatset-fewsol](https://hub.docker.com/r/irvlutd/meta-datatset-fewsol)[3] can be used as well. It's build upon [2] and contains all the packages for conducting the experiments. Use `latest` tag for image without models.
    - ```bash
      docker run --gpus all -id --rm -v <cloned-meta-dataset-dir-path>:/workspace --workdir=/workspace --name fewsol irvlutd/meta-datatset-fewsol:latest
      ```
    - All the required packages and models (from the extended study with better performance) are readily available in [3]. If any issues arise, please use the contact mediums mentioned [Contact](#contact) section.
        - Model location within the docker container: `/workspace/experiment_output`
            - `/workspace/experiment_output/tesla` contains models trained with tesla's `cluttered support set` setup.
            - `/workspace/experiment_output/tesla-filtered` contains models trained with tesla's `clean support set` setup.
            - `/workspace/experiment_output/pretrained-backbones` contains pretrained backbone models trained with `imagenet`.
- The experiments have been done using [2]. The packages' version in `requirements.txt` have been set accordingly. This may vary w.r.t. [*].
- Models will be saved with `<model-alias>_all-<num-validation-episodes><phrase>-<backbone>`
  - `<model-alias>`: alias used in [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5)
  - `<num-validation-episodes>`: Number of validation episodes used during training
  - `<phrase>`: If pretrained backbone is used then "-using-pretrained-backbone" else ""
  - `<backbone>`: alias of the backbone used in [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5)
### Alias
- **FewSOL** has been nicknamed `TESLA` in the codebase. This is due to the fact that at the start of the project, the name of the dataset was not decided and FewSOL was finalized as it promptly describes its purpose. Hence, when referring to any code related to FewSOL search for `TESLA, Tesla, tesla` keywords in the codebase. (If you are curious, `TESLA` stands for mul**T**i-view RGB-D dataset for f**E**w-**S**hot **L**e**A**rning)
- The test data variants for few-shot classification and joint object segmentation and few-shot classification have code aliases as follows:

    |     **Variant**    	| **Classes** 	|         **Alias**         	|
    |:------------------:	|:-----------:	|:-------------------------:	|
    |         All        	|      52     	|       tesla-mixture       	|
    |       Unseen       	|      41     	|        tesla-unseen       	|
    |        Seen        	|      11     	|         tesla-seen        	|
    | Unseen (Synthetic) 	|      13     	| tesla-synthetic-unseen-13 	|

- **NOTE**: Henceforth, these aliases will be used.

### Setup
```bash
# clone
git clone https://github.com/IRVLUTD/meta-dataset.git; cd meta-dataset;

# If you want to use docker, open docker container in interactive mode

# Install necessary packages
apt-get update; # required for docker
apt install python3-tk pkg-config libcairo2-dev python-gi \
            python-gi-cairo python3-gi python3-gi-cairo gir1.2-gtk-3.0;

# install dependencies
pip install -r requirements.txt
python setup.py install 

# In order to use data.read_episodes module, task_adaptation code is required
# as per https://github.com/google-research/meta-dataset#adding-task_adaptation-code-to-the-path
git clone https://github.com/google-research/task_adaptation.git
cd task_adaptation; python setup.py install; cd ..; 
export PYTHONPATH=$PYTHONPATH:$PWD
```

- **For using Clean/Cluttered support set setup**
  - Set `perform_filtration`=True/False in [trainer_config.gin](meta_dataset/learn/gin/setups/trainer_config.gin)
- **REQUIRED:** Copy all scripts to the `cloned` directory
    - `cp scripts/* .` 

### Environment Variables Setup
  - Be sure to set the env variables in [set_env.sh](set_env.sh) and [usr.env](usr.env).
    - 
  - Set respective dataset names in [all_datasets.gin](meta_dataset/learn/gin/setups/all_datasets.gin).
  - **NOTE**: Any gin parameter initialized via the shell script files starting with "__" will override them. Please be careful about the parameters initialized via script files. Use the mandatory ones in scripts and keep the rest inside respective gin configs.


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

### Citation:
Please cite the following if you incorporate our work.

```bibtex
Coming soon...
```

### Contact
Following 3 options are available for any clarification, comments or suggestions
- Join the [discussion forum](https://github.com/IRVLUTD/meta-dataset/discussions/). TODO: create a discussion forum.
- Create an [issue](https://github.com/IRVLUTD/meta-dataset/issues).
- Contact [Jishnu](https://jishnujayakumar.github.io/).