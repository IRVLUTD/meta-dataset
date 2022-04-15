chkpt_suffix="-$2"
pretrained_phrase=""

if test "$2" = ""
then
   chkpt_suffix=""
fi

if test "$3" = "use_pretrained_backbone"
then
   pretrained_phrase="-using-pretrained-backbone"
fi

suffix=""
if test "$1" = "True"
then
   suffix="-filtered"
fi
