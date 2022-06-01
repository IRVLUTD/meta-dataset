model=$1
gpu_id=$2
perform_filtration=$3
num_valid_episodes=$4
use_pretrained_backbone=$5
backbone=$6
bestnum=$7

for tesla_dataset_variant in tesla-mixture tesla-unseen tesla-seen tesla-synthetic-unseen-13
# for tesla_dataset_variant in tesla-synthetic-unseen-13
do
    # For each trained model it is possible test on w/wo filtered tesla variants
    for perform_filtration_ds in False True
    do
        bash __test.sh \
        $model \
        $gpu_id \
        $perform_filtration \
        $perform_filtration_ds \
        $num_valid_episodes \
        $tesla_dataset_variant \
        $use_pretrained_backbone \
        $backbone \
	    $bestnum
    done
done

# set the tesla symbolic link to tesla-unseen, reset to default
source set_env.sh
cd $RECORDS; rm tesla; ln -s tesla-unseen tesla; cd $ROOT_DIR;

# To check whether symbolic link points to tesla-unseen
ls -l $RECORDS
