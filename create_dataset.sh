#!/bin/bash
source libbashmenu.sh
WORKDIR "$1"
cd "$DIR"
#Проверка папок
if ! [ -d experiments ]; then
	EXPERIMENT_DIR_OK="Directory "experiments" not found\n"
fi
if ! [ -d data ]; then
	DATA_DIR_OK="Directory "data" not found\n"
fi
if ! [ -d configs ]; then
	MODEL_CONFIG_OK="Directory "configs" not found\n"
fi
if [[ $EXPERIMENT_DIR_OK != ""  || $DATA_DIR_OK != "" || $MODEL_CONFIG_OK != "" ]]
then
	whiptail --title  "Error" --msgbox  "$EXPERIMENT_DIR_OK$DATA_DIR_OK$MODEL_CONFIG_OK" 0 0
	unset EXPERIMENT_DIR_OK DATA_DIR_OK MODEL_CONFIG_OK
	exit
fi
RUN=`MENU SELECT_DIR_N "Select result directory" "Select dir" "" data`; EXIT $?
export RESULT_DIR=`realpath --relative-to="$DIR" "$RUN"`

OPTIONS=(	1 "Folderwise (default)"
		2 "Random"
		3 "Manual")
CHOICE=$(whiptail --clear --title "Select strategy" --menu "Choose strategy, default is folderwise"  0 0 0 "${OPTIONS[@]}" 2>&1 >/dev/tty); EXIT $?
case $CHOICE in
1)
	export STRATEGY="folderwise"
	;;
2)
	export STRATEGY="random"
	;;
3)
	export STRATEGY="manual"
	;;
esac

#export STRATEGY=$(whiptail --title  "$TITLEstrategy" --inputbox  "Type Strategy" 10 60 3>&1 1>&2 2>&3); EXIT $?
#exit; fi

RUN=`MENU SELECT_DIR_N "Select train directory" "Select dir" "" markup`; EXIT $?
export TRAIN=`realpath --relative-to="$DIR" "$RUN"`

if [[ $STRATEGY == "manual" ]]
then
	RUN=`MENU SELECT_DIR_N "Select test directory" "Select dir" "" markup`; EXIT $?
	TEST=`realpath --relative-to="$DIR" "$RUN"`
else
	TEST=$(whiptail --title  "$TITLE Train/Test split" --inputbox  "Input test percentage (Example: 0.2)" 0 0 3>&1 1>&2 2>&3)
	EXIT $?
fi

if (whiptail --title  "Create eval" --yesno "Create eval?\n" 0 0)
then
	RUN=`MENU SELECT_DIR_N "Select eval directory" "Select dir" "" markup`; EXIT $?
	export EVAL=`realpath --relative-to="$DIR" "$RUN"`
else
	export EVAL="No"	
fi

LABEL=$(whiptail --title  "$TITLElabel" --inputbox  "Type label (or use auto)" 10 60 3>&1 1>&2 2>&3); EXIT $?

OPTIONS2=(	1 "Create dataset"
		2 "Create dataset and zip archive"
		3 "Exit")
CHOICE2=$(whiptail --clear --title "Create dataset confirmation" --menu "Create dataset with this parameters?" 0 0 0 "${OPTIONS2[@]}" 2>&1 >/dev/tty); EXIT $?

if [[ $EVAL != "No" ]]
then
    EVAL_ARG="--eval=$EVAL "
else
    EVAL_ARG=""
fi

case $CHOICE2 in
1)
	echo "python3 create_dataset.py $RESULT_DIR $TRAIN $TEST $EVAL_ARG --labels=$LABEL --strategy=$STRATEGY" >> menus/commands_history
	python3 create_dataset.py "$RESULT_DIR" "$TRAIN" "$TEST" $EVAL_ARG --labels="$LABEL" --strategy="$STRATEGY"
	;;
2)
	echo "python3 create_dataset.py $RESULT_DIR $TRAIN $TEST $EVAL_ARG --labels=$LABEL --strategy=$STRATEGY --archive" >> menus/commands_history
	python3 create_dataset.py "$RESULT_DIR" "$TRAIN" "$TEST" $EVAL_ARG --labels="$LABEL" --strategy="$STRATEGY" --archive
	;;
3)
	echo "Exit"
	;;
esac

#if (whiptail --title  "Confirmation" --yesno "Create dataset with this parameters?\n \n Result dir: $RESULT_DIR\n Strategy: $STRATEGY\n Train: $TRAIN\n Test: $TEST\n Eval: $EVAL\n Label: $LABEL\n" 10 0)
#then
#     echo "python3 create_dataset.py $RESULT_DIR $TRAIN $TEST --eval=$EVAL --label=$LABEL --strategy=$STRATEGY --archive" >> menus/commands_history
#     python3 create_dataset.py "$RESULT_DIR" "$TRAIN" "$TEST" --eval="$EVAL" --label="$LABEL" --strategy="$STRATEGY" --archive
#fi