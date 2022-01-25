- This a forked repository of [Meta-Dataset](https://github.com/google-research/meta-dataset/). (Commit: [c67dd2b](https://github.com/google-research/meta-dataset/commit/c67dd2bb66fb2a4ce7e4e9906878e13d9b851eb5))
- Full documentation can be found [here](README-original.md)

### To run experiment, following commands can be used
```bash
# open docker container in interactive mode
docker run \
-it --rm --runtime=nvidia -p 7777:8888 \
-v ~/Documents/github/meta-dataset:/workspace \
--name meta-dataset__0 -e NVIDIA_VISIBLE_DEVICES=<list-of-gpu-ids> \
nvcr.io/nvidia/tensorflow:21.12-tf2-py3 # tensorflow 2

# install dependencies
pip install -r requirements.txt
python setup.py install

# bugs exist in the script, needs debugging
# hence download only required datasets
# recommended: imagenet only
bash install.sh

# reproduce the results
# trained on prototypical/matching networks
bash reproduce_best_results.sh

# evaluate the trained models
# tested on prototypical/matching networks
bash evaluate.sh
```
