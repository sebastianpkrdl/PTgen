#!/bin/bash

. $INIT_STEPS

if [[ ! -s $langmap ]]; then
  echo "Missing or empty langmap file $langmap. Check $1."; exit 1
fi

# Needs $datatype from run.sh's stage 3.
# (It would be nice to pass this in as $2 instead of as an explicit variable,
# but steps/init.sh insists on only one argument, the settings_file.)
case $datatype in
dev | eval)
  if [[ $TESTTYPE != $datatype ]]; then
    >&2 echo -e "\ncreate-datasplits.sh: when \$datatype == $datatype, so must \$TESTTYPE.  Aborting."; exit 1
  fi
esac

case $datatype in
train)
	LANG=( "${TRAIN_LANG[@]}" ); dtype="train"; ids_file=$trainids; splitids_file=$splittrainids ;;
adapt)
	LANG=( "${DEV_LANG[@]}"   ); dtype="train"; ids_file=$adaptids; splitids_file=$splitadaptids ;;
dev)
	LANG=( "${DEV_LANG[@]}"   ); dtype="dev";   ids_file=$testids;  splitids_file=$splittestids  ;;
eval)
	LANG=( "${EVAL_LANG[@]}"  ); dtype="test";  ids_file=$testids;  splitids_file=$splittestids  ;;
*)
	>&2 echo -e "\ncreate-datasplits.sh: Data split type $datatype should be [train|dev|adapt|eval].  Aborting."; exit 1
esac

mkdir -p "$(dirname "$ids_file")"
for L in ${LANG[@]}; do
	full_lang_name=`awk '/'$L'/ {print $2}' $langmap`
	sed -e 's:.wav::' -e 's:.mp3::' $LISTDIR/$full_lang_name/$dtype
done > $ids_file

split -n r/$nparallel $ids_file $tmpdir/split-$dtype.
mkdir -p "$(dirname "$splitids_file")"
for i in `seq 1 $nparallel`; do
	mv `ls $tmpdir/split-$dtype.* | head -1` ${splitids_file}.$i
done
