#!/bin/bash

# Source: https://github.com/google-research/meta-dataset/blob/main/doc/reproducing_best_results.md

export CUDA_VISIBLE_DEVICES="0";
export ROOT_DIR=$PWD;
export DATASRC="$ROOT_DIR/data";
export RECORDS="$ROOT_DIR/records";
export SPLITS="$ROOT_DIR/meta_dataset/dataset_conversion";
export EXPROOT=$ROOT_DIR/experiment_output;
export BS=1;
export SOURCE=imagenet;
# for MODEL in baselinefinetune prototypical matching maml maml_init_with_proto
for MODEL in prototypical baselinefinetune
do
  export EXPNAME=${MODEL}_${SOURCE}
  python -m meta_dataset.train \
    --records_root_dir=$RECORDS \
    --train_checkpoint_dir=${EXPROOT}/checkpoints/${EXPNAME} \
    --summary_dir=${EXPROOT}/summaries/${EXPNAME} \
    --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
    --gin_bindings="Trainer.experiment_name='$EXPNAME'" \
    --gin_bindings="Trainer.batch_size=$BS" \
    --gin_bindings="Trainer.checkpoint_to_restore=''" \
    --gin_bindings="Trainer.pretrained_source='scratch'"
done


# Following error was rectified by copying 
# meta_dataset/learn/gin/best/ to meta_dataset/learn/gin/best_v2/
# Error msg: Path not found: meta_dataset/learn/gin/best_v2/pretrained_resnet.gin