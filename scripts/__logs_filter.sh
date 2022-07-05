cd ..; source set_env.sh; cd scripts

logs_dir="$ROOT_DIR/logs"
out_file="$ROOT_DIR/test_results_from_logs.csv"

# test_mean_accuracy, test_margin_of_error forms the confidence interval
echo "experiment-setup, test_mean_accuracy, test_margin_of_error" > $out_file

for log_f in `ls $logs_dir/*.INFO`
do
    test_accuracy=`cat $log_f | tail -n2 | cut -d " " -f 6,7,8 | tr -d "\n" | head -c 22`
    echo "$log_f, $test_accuracy" >> $out_file
done

echo "Results gathered from $logs_dir are available in $out_file"