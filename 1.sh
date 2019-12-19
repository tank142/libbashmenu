#!/bin/bash
source libbashmenu.sh
WORKDIR "$1"
GRAPH_PATH=`MENU SELECT_FILE "Select experiment pb file" "Please select the file оr directory" "" experiments '*.pb' '*.ini' '*.yaml' '*.yml'`; EXIT $?
CSV_PATH=`MENU SELECT_FILE "Select experiment csv file" "Please select the file оr directory" "" data '*.csv'`; EXIT $?
THRESHOLD=`whiptail --title  "..." --inputbox  "threshold" 0 0 3>&1 1>&2 2>&3`; EXIT $?
SAVED_DETECTIONS_PATH="${GRAPH_PATH%/*/*/*}/eval/predictions.csv"
if [ -f "$SAVED_DETECTIONS_PATH" ]
then
	if (whiptail --title  "Confirmation" --yesno "Load saved detections from $SAVED_DETECTIONS_PATH ?" 0 0)
	then
		python3 eval.py ./"$GRAPH_PATH" ./"$CSV_PATH" --threshold="$THRESHOLD" --saved_detections_path="$SAVED_DETECTIONS_PATH"
	else
		python3 eval.py ./"$GRAPH_PATH" ./"$CSV_PATH" --threshold="$THRESHOLD"
	fi
else
	python3 eval.py ./"$GRAPH_PATH" ./"$CSV_PATH" --threshold="$THRESHOLD"
fi