# set the required env vars
models=$1
gpu_ids=$2
perform_filtration=$3 #True/False
num_valid_episodes=$4
backbone=$6

export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

source __set_suffix.sh $perform_filtration $num_valid_episodes $5
source set_env.sh

checkpoint_to_restore=''
pretrained_source=$SOURCE_FOR_PRETRAINING

for MODEL in $models 
do
    export EXPNAME=${MODEL}_${SOURCE}
    if test "$pretrained_source" = "imagenet"
    then
        # TODO: make the script compatible for using pretrained backbones
        PATH_PREFIX="${ROOT_DIR}/experiment_output/pretrained-backbones" #/best_pretrain_imagenet"
        
        BESTNUM=$(cat ${PATH_PREFIX}/best_pretrain_imagenet_${backbone}.txt | cut -d " " -f 2 | tail -n 1)
        checkpoint_to_restore="${PATH_PREFIX}/checkpoints/pretrain_imagenet_${backbone}/model_$BESTNUM.ckpt"

        # for differenciating models trained using backbones
        chkpt_suffix="${chkpt_suffix}${pretrained_phrase}-${backbone}"

    fi

    if test "$backbone" = "convnet"
    then
        backbone="four_layer_convnet"
    fi
    
    # train
    model="${EXPNAME}${chkpt_suffix}${pretrained_phrase}"
    if test "$backbone" = "" # default case
    then
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'" \
        --gin_bindings="Trainer.checkpoint_every=1000"

    elif test "$backbone" = "resnet34" # for tuning learning rate else train loss: NaN
    then
        model="${model}-${backbone}"
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Learner.embedding_fn=@${backbone}" \
        --gin_bindings="Trainer.learning_rate = 0.005052178216688174" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'" \
        --gin_bindings="Trainer.checkpoint_every=1000"
    else
        model="${model}-${backbone}"
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Learner.embedding_fn=@${backbone}" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'" \
        --gin_bindings="Trainer.checkpoint_every=1000"
    fi
done
