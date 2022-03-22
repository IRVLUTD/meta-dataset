#!/bin/bash
source set_env.sh
export SOURCE=all
# for MODEL in baseline baselinefinetune prototypical matching maml maml_init_with_proto
for MODEL in prototypical matching
do
  export EXPNAME=${MODEL}_${SOURCE}
  python -m meta_dataset.analysis.select_best_model \
    --all_experiments_root=$EXPROOT \
    --experiment_dir_basenames='' \
    --restrict_to_variants=${EXPNAME} \
    --description=best_${EXPNAME}
done
