# Use this script in GPU mode
# TODO: figure out why
# Doesn't work in normal mode: set is ''
# shouldn't be empty as it's TESLA 
# set should db either support or query

import sys
import tensorflow as tf 
raw_dataset = tf.data.TFRecordDataset(sys.argv[1])

for raw_record in raw_dataset.take(1):
    example = tf.train.Example()
    example.ParseFromString(raw_record.numpy())
    print(example)