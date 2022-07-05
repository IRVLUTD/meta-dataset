# git pull;

# scp required records (4.2-{gt, segmented})

# docker exec -it meta-dataset_jishnu__01 /bin/bash;

# test models
for i in "gt" "segmented"; 
do
    rm records-non-oversampled; ln -s records-4.2.$i/ records-non-oversampled;
    mkdir -p joint-segmentation-results.$i;
    for tesla_variant in "tesla-mixture" "tesla-unseen" "tesla-seen";
    do
        # # 260569
        # bash __test_joint_segmentation.sh  crosstransformer 0 False $tesla_variant 96500;     
        # bash __test_joint_segmentation.sh  prototypical 0 False $tesla_variant 40500;     
        # bash __test_joint_segmentation.sh  prototypical 0 True $tesla_variant 28500;
        # bash __test_joint_segmentation.sh  matching 0 True $tesla_variant 23500;     
        # bash __test_joint_segmentation.sh  matching 0 False $tesla_variant 35000;  
        # bash __test_joint_segmentation.sh  maml 0 False $tesla_variant 73000;  
        # bash __test_joint_segmentation.sh  maml_init_with_proto 0 False $tesla_variant 54000;     
        # bash __test_joint_segmentation.sh  baseline 0 True $tesla_variant 59500;  
        # bash __test_joint_segmentation.sh  baseline 0 False $tesla_variant 45000;  
        # # 260574
        # bash __test_joint_segmentation.sh  crosstransformer 0 True $tesla_variant 51000;   
        # bash __test_joint_segmentation.sh  crosstransformer_simclreps 0 False $tesla_variant 197000;   
        # bash __test_joint_segmentation.sh  crosstransformer_simclreps 0 True $tesla_variant 264500;   
        # bash __test_joint_segmentation.sh  baselinefinetune 0 True $tesla_variant 18000;   
        # bash __test_joint_segmentation.sh  maml 0 True $tesla_variant 53500;  
        # bash __test_joint_segmentation.sh  maml_init_with_proto 0 True $tesla_variant 35500;  
        # # 260570
        bash __test_joint_segmentation.sh  baselinefinetune 0 False $tesla_variant 60000;  
    done;
    mv joint-segmentation-results/* joint-segmentation-results.$i;
    rmdir joint-segmentation-results;
done

# parse test results
for i in "gt" "segmented";
do
    for training_setup in "clean" "cluttered";
    do
        pattern="$training_setup-training"
        for j in `ls joint-segmentation-results.$i/ | grep $pattern`;
        do
            k=joint-segmentation-results.$i/$j
            echo $k;
            cat $k | jq ."best_model"; cat $k | jq ."num_classes";
            cat $k | jq ."gt_query_samples"; cat $k | jq ."segmented_query_samples";
            cat $k | jq ."K"; cat $k | jq ."topK_all";
        done
    done
done

