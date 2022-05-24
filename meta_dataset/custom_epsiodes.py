import os
import gin
import json
import numpy as np
from meta_dataset.data import decoder
from meta_dataset.data import providers
from meta_dataset.data import dataset_spec as dataset_spec_lib

import tensorflow.compat.v1 as tf
tf.enable_eager_execution()


# set seed for reproducibility
seed = 1
tf.set_random_seed(seed)
np.random.seed(seed)


# dataset iterator
def iterate_dataset(dataset, n):
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

meta = {
    'tesla-mixture': 52,
    'tesla-unseen': 41,
    'tesla-seen': 11,
    'tesla-synthetic-seen-13': 13,
}

train_classes = 125
tesla_variant = list(meta.keys())[0]  # tesla-mixture
BASE_PATH = "/home/jishnu/Documents/github/meta-dataset/records-non-oversampled"
tfrecords_dir = f"{BASE_PATH}/{tesla_variant}/tesla"


GIN_FILE_PATH = 'meta_dataset/learn/gin/setups/data_config.gin'
gin.parse_config_file(GIN_FILE_PATH)

dataset_spec = dataset_spec_lib.load_dataset_spec(tfrecords_dir)

start = train_classes
end = start + meta[tesla_variant]

image_decoder = decoder.ImageDecoder(image_size=126)
support_images, support_class_ids, support_labels = [], [], []
query_images, query_class_ids, query_labels = [], [], []
class_id_label_map = {}

for class_label, class_id in enumerate(range(start, end)):
    class_id_label_map[class_id] = class_label
    # read tfrecords to TFRecordDataset
    raw_dataset = tf.data.TFRecordDataset(
        f"{tfrecords_dir}/{class_id}.tfrecords")
    #  read support images
    num_support = dataset_spec.images_per_class[class_id]['support']
    
    support_class_ids.extend([class_id] * num_support)
    support_labels.extend([class_label] * num_support)
    
    for idx, ele in iterate_dataset(raw_dataset, num_support):
#         print(type(ele))
        support_image, class_id, set = \
            image_decoder.decode_with_label_and_set(ele)
        support_images.extend(support_image)
#         print(idx, set)
#         break
#     break

query_images, query_class_ids, query_labels = \
    support_images, support_class_ids, support_labels

episode = \
    (support_images, support_labels, support_class_ids,
        query_images, query_labels, query_class_ids)
episode = providers.Episode(*episode)