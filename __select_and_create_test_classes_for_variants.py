import os
import shutil
import logging
from tqdm import tqdm

logging.basicConfig(level=logging.INFO)

"""
Once tfrecords for the 3 variants are produced and when the raw datasets are no longer
needed, then they could be deleted at user's discretion as training works uses tfrecords
"""

def log(message :str):
    """
    Logs a message
    Args: 
        message: A message to be logged 
    Retturns:
        Nothing
    """
    logging.info(message)


def get_required_classes(file_path :str):
    """
    Returns required class names from file
    Args:
        file_path of file
    Returns:
        classes mentioned in file
    """
    with open(file_path, 'r') as file:
        required_test_classes = file.read().splitlines()
        return required_test_classes


def mkdirp(dir):
    """
    Works similar to shell's mkdir -p
    """
    try:
            os.makedirs(dir)
    except:
        pass


dataset_directory = os.environ['DATASET_DOWNLOAD_DIR']
uncompressed_dataset_directory = os.environ['UNCOMPRESSED_DATASET_DIR_NAME']

tesla_classes_info_dir = f"{os.environ['ROOT_DIR']}/meta_dataset/dataset_conversion/tesla_classes_info"

# maps variant to required classes' file
variants = {
    "seen": 'train_test_comm_classes_with_query_set-11-seen.txt', # seen
    "unseen": 'train_test_disjoint_classes_with_query_set-41-unseen.txt', # unseen
    "mixture": 'test_classes_with_query_set-52-mixture.txt' # mixture
}

# Move to dataset_directory
os.chdir(dataset_directory)
log(f"Moved to {dataset_directory}")

for variant in variants.keys():
    dataset = f"tesla-{variant}"
    new_dataset_dir = os.path.join(dataset_directory, dataset)
    
    # remove old dataset dir if exists
    shutil.rmtree(new_dataset_dir, ignore_errors=True)
    
    # create new dataset dir
    mkdirp(new_dataset_dir)
    os.chdir(new_dataset_dir)
    
    train_src = os.path.join(dataset_directory, uncompressed_dataset_directory, "training_data")
    train_dst = os.path.join(new_dataset_dir, "training_data")
    os.symlink(train_src, train_dst) # create symlink

    log(f"Selecting test classes for {dataset} variant")

    required_test_classes = get_required_classes(
        os.path.join(tesla_classes_info_dir, variants[variant]))
    
    test_src_dir = os.path.join(dataset_directory, uncompressed_dataset_directory, "test_data")
    test_dst_dir = os.path.join(new_dataset_dir, "test_data")
    mkdirp(test_dst_dir)

    for test_class in tqdm(required_test_classes):
        test_src = os.path.join(test_src_dir, test_class)
        test_dst = os.path.join(test_dst_dir, test_class)
        log(f"linking \"{test_src}\" -> \"{test_dst}\"")
        os.symlink(test_src, test_dst) # create symlink
    
    os.chdir(dataset_directory)