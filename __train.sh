# set the required env vars
models=$1
gpu_ids=$2
perform_filtration=$3 #True/False
num_valid_episodes=$4
export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

source __set_suffix.sh $perform_filtration $num_valid_episodes
source set_env.sh

checkpoint_to_restore=''
pretrained_source=$SOURCE_FOR_PRETRAINING

# TODO: make the script compatible for using pretrained backbones
PATH_PREFIX="${ROOT_DIR}/experiment_output/pretrained-backbones" #/best_pretrain_imagenet"
# set BESTNUM to the "best_update_num" field in the corresponding best_....txt
export BESTNUM=$(grep best_update_num ${PATH_PREFIX}/best_${EXPNAME}${chkpt_suffix}.txt | awk '{print $2;}')
BEST_RESNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_resnet/model_${BESTNUM}.ckpt"
BEST_CONVNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_convnet/model_${BESTNUM}.ckpt"
BEST_WIDE_RESNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_convnet/model_${BESTNUM}.ckpt${PATH_PREFIX}_wide_resnet.pklz"

for MODEL in $models 
do
    if test "$pretrained_source" = "imagenet"
    then
        # select best checkpoint
        if test "$MODEL" = "prototypical"
        then
            checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
        elif test "$MODEL" = "matching"
        then
            checkpoint_to_restore=${BEST_CONVNET_CHECKPOINT_PATH}
        elif test "$MODEL" = "relationnet"
        then
            checkpoint_to_restore=${BEST_CONVNET_CHECKPOINT_PATH}
        elif test "$MODEL" = "maml"
        then
            checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
        elif test "$MODEL" = "maml_init_with_proto"
        then
            checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
        else
            echo "Error! Either SOURCE_FOR_PRETRAINING or MODEL given is wrong."
	        exit 1
        fi
    fi

    # train
    export EXPNAME=${MODEL}_${SOURCE}
    python -m meta_dataset.train \
    --records_root_dir=$RECORDS \
    --train_checkpoint_dir=${EXPROOT}/checkpoints/${EXPNAME}${chkpt_suffix} \
    --summary_dir=${EXPROOT}/summaries/${EXPNAME}${chkpt_suffix} \
    --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
    --gin_bindings="Trainer.experiment_name='$EXPNAME'" \
    --gin_bindings="Trainer.batch_size=$BS" \
    --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
    --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
    --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
    --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
done
