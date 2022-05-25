import os
import gin
import json
import numpy as np
from meta_dataset.data import decoder
from meta_dataset.data import providers
from meta_dataset.data import dataset_spec as dataset_spec_lib
from tqdm import tqdm

import tensorflow.compat.v1 as tf
tf.enable_eager_execution()


# set seed for reproducibility
seed = 1
tf.set_random_seed(seed)
np.random.seed(seed)


# dataset iterator
def iterate_dataset_n(dataset, n):
  if not tf.executing_eagerly():
    iterator = dataset.make_one_shot_iterator()
    next_element = iterator.get_next()
    with tf.Session() as sess:
      for idx in range(n):
        yield idx, sess.run(next_element)
  else:
    for idx, ele in enumerate(dataset):
      if idx == n:
        break
      yield idx, ele


# dataset iterator
def iterate_dataset(dataset):
  if not tf.executing_eagerly():
    iterator = dataset.make_one_shot_iterator()
    next_element = iterator.get_next()
    with tf.Session() as sess:
        yield idx, sess.run(next_element)
  else:
    for idx, ele in enumerate(dataset):
      yield idx, ele


meta = {
    'tesla-mixture': 52,
    'tesla-unseen': 41,
    'tesla-seen': 11,
    'tesla-synthetic-seen-13': 13,
}


GIN_FILE_PATH = 'meta_dataset/learn/gin/setups/data_config.gin'
gin.parse_config_file(GIN_FILE_PATH)


train_classes = 125
tesla_variant = list(meta.keys())[3]  # tesla-mixture
BASE_PATH = "/home/jishnu/Documents/github/meta-dataset/records-non-oversampled"
tfrecords_dir = f"{BASE_PATH}/tesla"
dataset_spec = dataset_spec_lib.load_dataset_spec(tfrecords_dir)

# Source file path
src = f"{BASE_PATH}/{tesla_variant}"

# Create a symbolic link
try:
    os.symlink(src, tfrecords_dir)
except:
    pass

start = train_classes
end = start + meta[tesla_variant]

image_decoder = decoder.ImageDecoder(image_size=126)
support_images, support_class_ids, support_labels = [], [], []
query_images, query_class_ids, query_labels = [], [], []
class_id_label_map = {}

print(f"Total classes: {meta[tesla_variant]}")
total_query_data, total_support_data = 0, 0
for class_label, class_id in enumerate(tqdm(range(start, end))):
    class_id_label_map[class_id] = class_label
    # read tfrecords to TFRecordDataset
    raw_dataset = tf.data.TFRecordDataset(
        f"{tfrecords_dir}/{class_id}.tfrecords")
    #  read support images
    num_support = dataset_spec.images_per_class[class_id]['support']
    num_query = 0
    
    for idx, example_string in iterate_dataset(raw_dataset):
        if idx < num_support:
            support_image, _, _ = \
              image_decoder.decode_with_label_and_set(example_string)
            support_images.append(support_image)
            support_class_ids.append(class_id)
            support_labels.append(class_label)
        else:
            query_image, _, _ = \
              image_decoder.decode_with_label_and_set(example_string)
            query_images.append(query_image)
            query_class_ids.append(class_id)
            query_labels.append(class_label)
            num_query += 1
    total_support_data += dataset_spec.images_per_class[class_id]['support']
    total_query_data += dataset_spec.images_per_class[class_id]['query']
    if num_query != dataset_spec.images_per_class[class_id]['query']:
        print(class_id, num_support, num_query, dataset_spec.images_per_class[class_id]['query'])
    # episode_skeleton_path = 'pkl/test.episode_skeleton.pkl'
# query_images, query_class_ids, query_labels = \
#     support_images, support_class_ids, support_labels

episode_skeleton_path = f'pkl/{tesla_variant}-episode.pkl'
episode = providers.Episode(
    support_images=support_images,
    support_class_ids=support_class_ids,
    support_labels=support_labels,
    query_images=query_images,
    query_class_ids=query_class_ids,
    query_labels=query_labels)

# print(episode)
import pickle
with open(episode_skeleton_path, 'wb') as pkl_file:
    pickle.dump(episode, pkl_file)