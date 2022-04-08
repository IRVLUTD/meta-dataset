chkpt_suffix="-$2"
# chkpt_suffix="-using-pretrained-backbones-$2"
suffix=""
if [ $1 == "True" ]
then
   suffix="-filtered"
fi
