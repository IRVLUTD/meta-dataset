import pandas as pd


def parse_experiment_setup(exp_setup):
    /home/jishnu/Documents/github/meta-dataset/logs/tesla-unseen
    +crosstransformer_all-60
    +model_50500-dataset-tesla-mixture-filtered.INFO
    train_data_info, model_info, dataset_setup_info = exp_setup.split("+")
    train_data = train_data_info.split("/")[-1]
    model_setup, num_valid_episodes = model_info.split("-")
    dataset_setup_info = dataset_setup_info.split("-")
    
    best_model_update_num = dataset_setup_info[0].split("_")[1]
    tesla_dataset_variant = "-".join(dataset_setup_info[2:4])
    suffix = dataset_setup_info[-1] if len(dataset_setup_info) > 3 else ""
    
    return

# read test_results from logs csv
data = pd.read_csv('test_results_from_logs.csv', header=0)

print(data)