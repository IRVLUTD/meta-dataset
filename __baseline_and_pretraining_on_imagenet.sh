# set the required env vars
backbones=$1
gpu_ids=$2
max_stride=$3 # only for crosstransformer resnet34
export CUDA_VISIBLE_DEVICES=$gpu_ids
source set_env.sh

# for imagenet filtration is not required
perform_filtration='False'
EXPROOT="${ROOT_DIR}/experiment_output/pretrained-backbones"
export EXPNAME=pretrain_imagenet

for BACKBONE in $backbones # resnet convnet wide_resnet resnet34 relationnet_convnet
do
  export JOBNAME=${EXPNAME}_${BACKBONE}
  model=$JOBNAME
  use_ema="False"
  if test "$max_stride" != "None"
  then
    model="$model-max-stride-$max_stride"
    use_ema="True"
  fi
  
  python -m meta_dataset.train \
    --records_root_dir=$RECORDS \
    --train_checkpoint_dir=${EXPROOT}/checkpoints/${model} \
    --summary_dir=${EXPROOT}/summaries/${model} \
    --gin_config=meta_dataset/learn/gin/best/${JOBNAME}.gin \
    --gin_bindings="Trainer.experiment_name='$model'" \
    --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
    --gin_bindings="resnet34.max_stride=$max_stride" \
    --gin_bindings="bn.use_ema=$use_ema" \
    --gin_bindings="EpisodeDescriptionConfig.max_support_size_contrib_per_class=100" # default value for MD imagenet
done