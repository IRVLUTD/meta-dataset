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
    if test "$MODEL" = "flute"
    then
        # TODO; set ckpt and summary path w.r.t. pretrained backbone argument, $5 and $6
        if test "$pretrained_source" = "imagenet"
        then
            checkpoint_to_restore='' # TODO: use a pretrained one from: https://console.cloud.google.com/storage/browser/gresearch/flute;tab=objects?pli=1&prefix=&forceOnObjectsSortingFiltering=false
        else
            checkpoint_to_restore='' # for pretrained_source == 'scratch' 
        fi
        # train flute
        export EXPNAME=${MODEL}_init_from_${pretrained_source}
        python -m meta_dataset.train_flute \
        --records_root_dir=$RECORDS \
        --train_checkpoint_dir=${EXPROOT}/checkpoints/${EXPNAME}${chkpt_suffix} \
        --summary_dir=${EXPROOT}/summaries/${EXPNAME}${chkpt_suffix} \
        --gin_config=meta_dataset/learn/gin/best_v2/${EXPNAME}.gin \
        --gin_bindings="Trainer_flute.experiment_name='$EXPNAME-all'" \
        --gin_bindings="Trainer_flute.batch_size=$BS" \
        # --gin_bindings="DataConfig.image_height=126" \
        --gin_bindings="Trainer_flute.num_eval_episodes=$num_valid_episodes" \
        --gin_bindings="Trainer_flute.perform_filtration=$perform_filtration" \
        --gin_bindings="Trainer_flute.checkpoint_to_restore='${checkpoint_to_restore}'" \
        --gin_bindings="Trainer_flute.pretrained_source='${pretrained_source}'"
    else
        export EXPNAME=${MODEL}_${SOURCE}
        if test "$pretrained_source" = "imagenet"
        then
            # TODO: make the script compatible for using pretrained backbones
            PATH_PREFIX="${ROOT_DIR}/experiment_output/pretrained-backbones" #/best_pretrain_imagenet"
            
            # BESTNUM_RESNET=$(cat ${PATH_PREFIX}/best_pretrain_imagenet_resnet.txt | cut -d " " -f 2 | tail -n 1)
            # BEST_RESNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_resnet/model_$BESTNUM_RESNET.ckpt"

            # BESTNUM_RESNET34=$(cat ${PATH_PREFIX}/best_pretrain_imagenet_resnet34.txt | cut -d " " -f 2 | tail -n 1)
            # BEST_RESNET34_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_resnet34/model_$BESTNUM_RESNET34.ckpt"
            
            # BESTNUM_CONVNET=$(cat ${PATH_PREFIX}/best_pretrain_imagenet_convnet.txt | cut -d " " -f 2 | tail -n 1)
            # BEST_CONVNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_convnet/model_$BESTNUM_CONVNET.ckpt"

            # BESTNUM_WIDE_RESNET=$(cat ${PATH_PREFIX}/best_pretrain_imagenet_wide_resnet.txt | cut -d " " -f 2 | tail -n 1)
            # BEST_WIDE_RESNET_CHECKPOINT_PATH="${PATH_PREFIX}/checkpoints/pretrain_imagenet_wide_resnet/model_$BESTNUM_WIDE_RESNET.ckpt"
            
            # TODO: select best checkpoint
            # if test "$MODEL" = "prototypical"
            # then
            #     checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
            # elif test "$MODEL" = "matching"
            # then
            #     checkpoint_to_restore=${BEST_WIDE_RESNET_CHECKPOINT_PATH}
            # elif test "$MODEL" = "relationnet"
            # then 
            #     checkpoint_to_restore=${BEST_CONVNET_CHECKPOINT_PATH}
            # elif test "$MODEL" = "maml"
            # then
            #     checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
            # elif test "$MODEL" = "maml_init_with_proto"
            # then
            #     checkpoint_to_restore=${BEST_RESNET_CHECKPOINT_PATH}
            # else
            #     echo "Error! Either SOURCE_FOR_PRETRAINING or MODEL given is wrong."
            #     exit 1
            # fi
            
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
        if test "$backbone" = "" # default case
        then
            model="${EXPNAME}${chkpt_suffix}"
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
            --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        elif test "$backbone" = "resnet34" # for tuning learning rate else train loss: NaN
        then
            model="${EXPNAME}${chkpt_suffix}-${backbone}"
            python -m meta_dataset.train \
            --records_root_dir=$RECORDS \
            --train_checkpoint_dir=${EXPROOT}/checkpoints/$model \
            --summary_dir=${EXPROOT}/summaries/$model \
            --gin_config=meta_dataset/learn/gin/best/${EXPNAME}.gin \
            --gin_bindings="Trainer.experiment_name='${model}'" \
            --gin_bindings="Trainer.batch_size=$BS" \
            --gin_bindings="DataConfig.image_height=126" \
            --gin_bindings="Learner.embedding_fn=@${backbone}" \
            --gin_bindings="Trainer.learning_rate = 0.001052178216688174" \
            --gin_bindings="Trainer.num_eval_episodes=$num_valid_episodes" \
            --gin_bindings="Trainer.perform_filtration=$perform_filtration" \
            --gin_bindings="Trainer.checkpoint_to_restore='${checkpoint_to_restore}'" \
            --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        else
            model="${EXPNAME}${chkpt_suffix}-${backbone}"
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
            --gin_bindings="Trainer.pretrained_source='${pretrained_source}'"
        fi
    fi
done
