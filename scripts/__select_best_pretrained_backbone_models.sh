EXPROOT="$PWD/experiment_output/pretrained-backbones"
backbones=$1
for BACKBONE in $backbones #resnet convnet wide_resnet resnet34 relationnet_convnet
do
  export JOBNAME=pretrain_imagenet_${BACKBONE}
  if test "$BACKBONE" = "resnet34_ctx"
  then
      BACKBONE="resnet34"
      export JOBNAME="pretrain_imagenet_${BACKBONE}-max-stride-16"
  fi 
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${JOBNAME} \
    --description=best_${JOBNAME}
done
