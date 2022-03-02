source set_env.sh
OUTPUT_DIR="DUMPED_EPISODES"
for DATASET in tesla; do \
    python -m meta_dataset.data.dump_episodes \
        --dataset_name=${DATASET} \
        --output_dir=${OUTPUT_DIR}/${DATASET} \
        --num_episodes=50 \
        --records_root_dir=${RECORDS} \
        --gin_config=meta_dataset/learn/gin/setups/data_config_string.gin \
        --gin_config=meta_dataset/learn/gin/setups/variable_way_and_shot.gin \
        --gin_bindings="DataConfig.num_prefetch=64"; \
done
