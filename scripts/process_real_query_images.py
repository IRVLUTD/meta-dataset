import os
import io
import json
import logging
from PIL import Image
from tqdm import tqdm
import tensorflow.compat.v1 as tf
tf.disable_eager_execution()

from meta_dataset.dataset_conversion.dataset_to_records \
    import get_example


"""
This script reads query images from sample_query/ dir and 
transform to bytes and write to 0.tfrecords

All sample query images become the part of 0.tfrecords
All other *.tfrecords are void of query images, i.e. contain support images only

This is helpful as the output is predicted object class names.
No metric calculation is done.

Since only 32 objects are used, top-1 and top-5 accuracy 
for the real world testing is calculated manually.
"""


def load_and_process_image(path):
    """Process the image living at path if necessary.
    Args:
        path: the path to an image file (e.g. a .png file).
    Returns:
        A bytes representation of the encoded image.
    """
    with tf.io.gfile.GFile(path, 'rb') as f:
        image_bytes = f.read()
    try:
        img = Image.open(io.BytesIO(image_bytes))
    except:
        logging.warn('Failed to open image: %s', path)
        raise

    img_needs_encoding = False
    output_format = 'JPEG'
    if img.format != output_format:
        img_needs_encoding = True
    if img.mode != 'RGB':
        img = img.convert('RGB')
        img_needs_encoding = True

    if img_needs_encoding:
        # Convert the image into output_format
        buf = io.BytesIO()
        img.save(buf, format=output_format)
        buf.seek(0)
        image_bytes = buf.getvalue()
    return image_bytes
        

def iterate_dataset(dataset):
  if not tf.executing_eagerly():
    iterator = dataset.make_one_shot_iterator()
    next_element = iterator.get_next()
    with tf.Session() as sess:
        while True:
            try:
                yield sess.run(next_element)
            except:
                break
  else:
    for episode in dataset:
      yield episode


def read_and_transform_query_images(query_img_dir, records_path):
    class_label, total_query_images = 0, 0
    orig_dataset_path = os.path.join(records_path, f"{class_label}.tfrecords.og")
    new_dataset_path = os.path.join(records_path, f"{class_label}.tfrecords")

    orig_dataset = tf.data.TFRecordDataset(orig_dataset_path)
    writer = tf.python_io.TFRecordWriter(new_dataset_path)

    # write support images as example strings
    for support_example in iterate_dataset(orig_dataset):
        writer.write(support_example)

    # write query images as example strings
    for image_file in tqdm(os.listdir(query_img_dir)):
        query_img_path = os.path.join(query_img_dir, image_file)
        img = load_and_process_image(query_img_path)
        query_example = get_example(data_bytes=img, class_label=class_label, belongs_to_set=b'query')
        writer.write(query_example)
        total_query_images += 1

    # close writer
    writer.close()

    # update data_spec.json
    orig_dataset_spec_path = os.path.join(records_path, "dataset_spec.og.json")
    new_dataset_spec_path = os.path.join(records_path, "dataset_spec.json")

    with open(orig_dataset_spec_path, 'r') as ds_spec_file:
        dataset_spec = json.load(ds_spec_file)
        dataset_spec["images_per_class"][str(class_label)]["query"] = total_query_images
    
    with open(new_dataset_spec_path, 'w') as ds_spec_file:
        dataset_spec = json.dump(dataset_spec, ds_spec_file)

    # run the experiment

if __name__ == "__main__":
    cwd = os.getcwd()
    query_img_dir = os.path.join(cwd, "sample_query")

    # make sure records-non-oversampled points to correct records
    records_path = os.path.join(cwd, "records-non-oversampled", "tesla")

    # read query images and transform to bytes and write to 0.tfrecords
    read_and_transform_query_images(query_img_dir, records_path)

