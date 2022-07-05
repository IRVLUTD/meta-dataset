# set the required env vars
models=$1
gpu_ids=$2
perform_filtration=$3 #True/False
num_valid_episodes=$4
backbone=$6

export SOURCE=all #tesla
export CUDA_VISIBLE_DEVICES=$gpu_ids

checkpoint_to_restore=''
pretrained_source=$SOURCE_FOR_PRETRAINING

source __set_suffix.sh $perform_filtration $num_valid_episodes $5
source set_env.sh

image_height=126

for MODEL in $models 
do
    export EXPNAME=${MODEL}_${SOURCE}

    if [ "$MODEL" == "baselinefinetune" ];
    then
	image_height=84
    fi

    if test "$pretrained_source" = "imagenet"
    then
        # TODO: make the script compatible for using pretrained backbones
        PATH_PREFIX="${ROOT_DIR}/experiment_output/pretrained-backbones" #/best_pretrain_imagenet"
        __phrase="pretrain_imagenet_${backbone}"
        if test "$backbone" = "resnet34_ctx"
        then
            backbone="resnet34"
            __phrase="pretrain_imagenet_${backbone}-max-stride-16"
        fi 
        BESTNUM=$(cat ${PATH_PREFIX}/best_${__phrase}.txt | cut -d " " -f 2 | tail -n 1)
        checkpoint_to_restore="${PATH_PREFIX}/checkpoints/${__phrase}/model_$BESTNUM.ckpt"
    fi

    if test "$backbone" = "convnet"
    then
        backbone="four_layer_convnet"
    fi
    
    # train
    if test "$backbone" = "" # default case
    then
        model="${EXPNAME}${chkpt_suffix}${pretrained_phrase}"
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=${image_height}" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.test_entire_test_set_using_single_episode=False" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        # --gin_bindings="Trainer.checkpoint_every=1000"

    elif test "$backbone" = "resnet34" # for tuning learning rate else train loss: NaN
    then
        model="${EXPNAME}${chkpt_suffix}${pretrained_phrase}-${backbone}"
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=${image_height}" \
        --gin_bindings="Learner.embedding_fn=@${backbone}" \
        --gin_bindings="Trainer.learning_rate = 0.001052178216688174" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.test_entire_test_set_using_single_episode=False" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        # --gin_bindings="Trainer.checkpoint_every=1000"
    else
        model="${EXPNAME}${chkpt_suffix}${pretrained_phrase}-${backbone}"
        python -m meta_dataset.train \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
        --summary_dir=${EXPROOT}/summaries/$model \
        --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
        --gin_bindings="Trainer.experiment_name='${model}'" \
        --gin_bindings="Trainer.batch_size=$BS" \
        --gin_bindings="DataConfig.image_height=${image_height}" \
        --gin_bindings="Learner.embedding_fn=@${backbone}" \
        --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer.test_entire_test_set_using_single_episode=False" \
        --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        # --gin_bindings="Trainer.checkpoint_every=1000"
    fi
done
