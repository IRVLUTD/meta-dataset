EXPROOT="$PWD/experiment_output/pretrained-backbones"

for BACKBONE in resnet convnet wide_resnet
do
  export JOBNAME=pretrain_imagenet_${BACKBONE}
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${JOBNAME} \
    --description=best_${JOBNAME}
done
