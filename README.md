- This a forked repository of [Meta-Dataset](https://github.com/google-research/meta-dataset/). (Commit: [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5))
- Full documentation can be found [here](README-original.md).

### To run experiment, following commands can be used
```bash
# open docker container in interactive mode
docker run \
-it --rm --runtime=nvidia -p 7777:8888 \
-v <cloned-meta-dataset-dir-path>:/workspace \
--name meta-dataset__0 -e NVIDIA_VISIBLE_DEVICES=<list-of-gpu-ids> \
nvcr.io/nvidia/tensorflow:21.12-tf2-py3 # tensorflow 2

# install dependencies
pip install -r requirements.txt
python setup.py install

# bugs exist in the script, needs debugging
# hence download only required datasets
# recommended: imagenet only
# bash install.sh

source set_env.sh
export BS=1;

# Download the TESLA dataset
# TODO: populate url after paper publication
wget <dataset-url>
7za x FSL-Sim2Real-IRVL-2022.7z # decompress

# Assumption TESLA is decompressed to $DATASRC/TESLA directory
python -m meta_dataset.dataset_conversion.convert_datasets_to_records   \
--dataset=tesla --tesla_data_root=$DATASRC/TESLA --splits_root=$SPLITS \
--records_root=$RECORDS

# reproduce the results
# trained on prototypical/matching networks
# bash reproduce_best_results.sh

# Train using TESLA
bash __run_using_tesla.sh

# evaluate the trained models
# tested on prototypical/matching networks
bash evaluate.sh
```

### Graphs for Loss/Accuracy during reproduction attempt
Training <br>
<img src="./img/train_1_loss.svg" alt="Train-Loss" width="300"/><img src="./img/train_1_acc.svg" alt="Train-Accuracy" width="300"/><br>
Validation <br>
  <img src="./img/valid_1_loss.svg" alt="Valid-Loss" width="300"/><img src="./img/valid_1_acc.svg" alt="Valid-Accuracy" width="300"/> <br>

- **Note**
  - Orange - Matching Network
  - Blue - Prototypical Network

### Evaluation results
- Based on training done using the [updated_data_config_common.gin](./meta_dataset/learn/gin/setups/data_config_common.gin) due to memory constraints on Lab PC. 
- **Best variant**: prototypical_imagenet. 
  - **Best valid acc**: 0.2996023893356323. 
  - **Best update num**: 69500.
- **Best variant**: matching_imagenet. 
  - **Best valid acc**: 0.25817540287971497. 
  - **Best update num**: 42500. 
