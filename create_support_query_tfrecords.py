from tqdm import tqdm
from meta_dataset.data import dataset_spec as dataset_spec_lib
import os
import tensorflow.compat.v1 as tf

tf.disable_eager_execution()


# dataset iterator
def iterate_dataset(dataset):
  if not tf.executing_eagerly():
    iterator = dataset.make_one_shot_iterator()
    next_element = iterator.get_next()
    with tf.Session() as sess:
      idx = -1
      while True:
        try:
          idx += 1
          yield idx, sess.run(next_element)
        except:
          break
  else:
    for idx, ele in enumerate(dataset):
      yield idx, ele


meta = {
    'tesla-mixture': 52,
    'tesla-unseen': 41,
    'tesla-seen': 11,
    'tesla-synthetic-unseen-13': 13,
}

ROOT_DIR = os.getcwd()

train_classes = 125
BASE_PATH = f"{ROOT_DIR}/records-non-oversampled"
tfrecords_dir = f"{BASE_PATH}/tesla"

for tesla_variant in meta.keys():

  print(tesla_variant)
  # Source file path
  src = f"{BASE_PATH}/{tesla_variant}"

  # Create a symbolic link
  try:
      os.symlink(src, tfrecords_dir)
      print("+")
  except:
      os.remove(tfrecords_dir)
      os.symlink(src, tfrecords_dir)

  dataset_spec = dataset_spec_lib.load_dataset_spec(tfrecords_dir)

  start = train_classes
  end = start + meta[tesla_variant]
  print(f"Creating one tfrecord file for Tesla variant: {tesla_variant} | Total classes: {meta[tesla_variant]}")

  try:
      os.mkdir(f"{ROOT_DIR}/support_query_records")
  except:
      pass

  support_output_path = f"{ROOT_DIR}/support_query_records/{tesla_variant}.support.tfrecords"
  query_output_path = f"{ROOT_DIR}/support_query_records/{tesla_variant}.query.tfrecords"
  support_writer = tf.python_io.TFRecordWriter(support_output_path)
  query_writer = tf.python_io.TFRecordWriter(query_output_path)

  # iterate through all the test classes
  for class_label, class_id in enumerate(tqdm(range(start, end))):
      # read tfrecords to TFRecordDataset
      raw_dataset = tf.data.TFRecordDataset(
          f"{tfrecords_dir}/{class_id}.tfrecords")
      #  read support images
      num_support = dataset_spec.images_per_class[class_id]['support']

      for idx, example_string in iterate_dataset(raw_dataset):
        # example_serial = example_string.SerializeToString()
        if idx < num_support:
            support_writer.write(example_string)
        else:
            query_writer.write(example_string)

  support_writer.close()
  query_writer.close()

