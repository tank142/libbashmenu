#!/bin/bash
source libbashmenu.sh
WORKDIR "$1"
RUN=`MENU SELECT_FILE "Select experiment ini file" "Please select the file оr directory" "" experiments '*.ini'`; EXIT $?
#if [[ `file "$RUN"` == *text* ]]
#then
#	realpath --relative-to="$DIR" "$RUN"
#fi
SETTINGS_PATH=`realpath --relative-to="$DIR" "$RUN"`
python3 get_config.py "$SETTINGS_PATH" --export

