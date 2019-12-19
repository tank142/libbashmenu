#!/bin/bash
source libbashmenu.sh
export MENU=" create_experiment.sh "
WORKDIR "$1"
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

EXPERIMENT_DIR=`MENU SELECT_DIR_N "Select experiment directory" "$MENU" "" experiments`; EXIT $?
DATA_DIR=`MENU SELECT_DIR_N "Select data directory" "$MENU" "" data`; EXIT $?
MODEL_CONFIG=`MENU SELECT_FILE "Select config file" "$MENU" "" configs '*.config'`; EXIT $?
CLASS_LIST=$(whiptail --title  "$MENU" --inputbox  "Type classes" 10 60 3>&1 1>&2 2>&3); EXIT $?
if (whiptail --title  "Confirmation" --yesno "Create experiment with this parameters?\n \n $EXPERIMENT_DIR\n $DATA_DIR\n $MODEL_CONFIG\n $CLASS_LIST\n" 0 0)
then
	EXPERIMENT_DIR=`realpath --relative-to="$DIR" "$EXPERIMENT_DIR"`
	DATA_DIR=`realpath --relative-to="$DIR" "$DATA_DIR"`
	MODEL_CONFIG=`realpath --relative-to="$DIR" "$MODEL_CONFIG"`
	echo "python3 create_experiment.py $EXPERIMENT_DIR $DATA_DIR $CLASS_LIST $MODEL_CONFIG" #>> "$DIR"/menus/commands_history
	python3 create_experiment.py "$EXPERIMENT_DIR" "$DATA_DIR" "$CLASS_LIST" "$MODEL_CONFIG"
fi
