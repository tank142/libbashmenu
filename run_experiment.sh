#!/bin/bash
source libbashmenu.sh
WORKDIR "$1"
RUN=`MENU SELECT_FILE "Select experiment ini file" "Please select the file оr directory" "" experiments '*.ini'`; EXIT $?
SETTINGS_PATH=`realpath --relative-to="$DIR" "$RUN"`
echo "./run.sh $SETTINGS_PATH" >> "$DIR"/menus/commands_history
./run.sh "$SETTINGS_PATH"

