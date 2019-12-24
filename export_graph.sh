#!/bin/bash
source libbashmenu.sh
export INTERFACE="dialog"
export MENU=" export_graph.sh "
WORKDIR "$1"
FILE=`MENU FIND_OBJECT "Select checkpoint" "$MENU" "" ./experiments/my_cool_experiment/ '.ckpt-' '.meta'`; EXIT $?
DIRc="${FILE%/*}"
EXPORT_DIR=`$INTERFACE --title  "$MENU" --inputbox  "Export dir" 8 60 "$DIRc/exported_inference_graphs" 3>&1 1>&2 2>&3`; EXIT $?
if ($INTERFACE --title  "Confirmation" --yesno "export on cpu?" 0 0)
then
	python3 export_inference_graph.py "$FILE" --cpu -o "$EXPORT_DIR"
	echo "python3 export_inference_graph.py $FILE --cpu -o $EXPORT_DIR" >> "$DIR"/menus/commands_history
else
	python3 export_inference_graph.py "$FILE" -o "$EXPORT_DIR"
	echo "python3 export_inference_graph.py $FILE -o $EXPORT_DIR" >> "$DIR"/menus/commands_history
fi