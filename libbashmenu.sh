HELP(){
echo -e "\e[1;34mБиблиотека для построения интерфейсов

\e[1;33mHELP
\e[1;39mВыводит этот текст помощи.

\e[1;33mMENU SELECT_FILE
\e[1;39mМеню выбора файла.
Если oпция опция '--up' передана, всегда отображается переход к верхней папке.
MENU SELECT_FILE	\"Текст внутри окна\" \"Текст в шапке окна\" \"Текст на заднем фоне\" [папка в которой откроется меню] '*.config' --up

\e[1;33mMENU FIND_OBJECT
\e[1;39mМеню выбора файла, отображает только содержимое между аргументами.
MENU FIND_OBJECT	\"Текст внутри окна\" \"Текст в шапке окна\" \"Текст на заднем фоне\" [папка в которой откроется меню] '.ckpt-' '.meta' --up

\e[1;33mMENU SELECT_DIR_N
\e[1;39mМеню выбора папки.
MENU SELECT_DIR_N	\"Текст внутри окна\" \"Текст в шапке окна\" \"Текст на заднем фоне\" [папка в которой откроется меню] --up
WORKDIR

\e[1;39mПеременная INTERFACE позволяет указать программу для отображения окон. dialog, Xdialog, whiptail и т.д.

\e[1;33mMENU MKFILE
\e[1;39mМеню создания файла, использует редактор из переменной TEXTEDITOR.

\e[1;33mMENU MKDIR
\e[1;39mМеню создания папки.

\e[1;33mMENU RM
\e[1;39mМеню удаления.

\e[1;33mWORKDIR
\e[1;39mМеняет рабочий каталог и записывает полный путь к нему в глобальной переменной 'DIR'. Обязательна для работы меню.

\e[1;33mEXIT
\e[1;39mВыполняет команду exit, если код завершения не равен нулю.

\e[1;34mВнутренние функции:

\e[1;33mFILELIST_ALL
\e[1;39mДелает массив ALL с содержимым папки.

\e[1;33mFILELIST
\e[1;39mСоздаёт пункты меню из массива ALL

\e[1;33mFILELIST_OBJECT '.ckpt-' '.meta'
\e[1;39mСоздаёт пункты меню по фильтру

\e[1;33mFILELIST_ONLY_DIRS
\e[1;39mДобавляет только папки в пункты меню

\e[1;33mFILELIST_FILE '*.config'
\e[1;39mДобавляет только файлы по фильтру в пункты меню

\e[1;33mSORT
\e[1;39mПринимает вывод из команды sort и создаёт пункты меню.

\e[0m"
}

MENU(){
	local files RUN ALL INFO
	case $1 in
	FIND_OBJECT)
		CDDIR "$5"
		CD "$dir" "$8"
		FILELIST_ALL
		FILELIST_OBJECT "$6" "$7"
		FILELIST_ONLY_DIRS
		case "$INTERFACE" in
			dialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			Xdialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 $(( ${#files[@]} / 2 + 1 ))"
			;;
			whiptail)
				SIZE="0 0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			*)
				SIZE="0 0 0"
			;;
		esac
		if [[ "${files[@]}" != "" ]]
		then
			RUN=$($INTERFACE --backtitle "$4" --title "$3" --menu "$2" $SIZE "${files[@]}" 3>&1 1>&2 2>&3)
			case $? in
				0)
				if [[ `file "$RUN"` == *': directory'* || `file "$RUN"` == *', directory'* ]]
				then
					cd "$RUN"
					MENU FIND_OBJECT "$2" "$3" "$4" "" "$6" "$7" "$8"
				else
					if [[ "$RUN" == ".." ]]
					then
						$RUN
					else
						DIRc=`pwd`
						echo `realpath --relative-to="$DIR" "$DIRc"/*$RUN*$7*`
					fi
				fi
				;;
				*)
				exit "$?"
				;;
			esac
		fi
	;;
	SELECT_DIR_N)
		CDDIR "$5"
		files[i]="[Select_this_dir]"
		files[i+1]=""
		((i+=2))
		((s++))
		#Новая папка
		files[i]="[MKDIR]"
		files[i+1]=""
		((i+=2))
		((s++))
		CD "$dir" "$6"
		FILELIST_ALL
		FILELIST_ONLY_DIRS
		case "$INTERFACE" in
			dialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			Xdialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 $(( ${#files[@]} / 2 + 1 ))"
			;;
			whiptail)
				SIZE="0 0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			*)
				SIZE="0 0 0"
			;;
		esac
		if [[ "${files[@]}" != "" ]]
		then
			RUN=$($INTERFACE --backtitle "$4" --title "$3" --menu "$2" $SIZE "${files[@]}" 3>&1 1>&2 2>&3)
			case $? in
				0)
				if [[ `file "$RUN"` == *': directory'* || `file "$RUN"` == *', directory'* ]]
				then
					cd "$RUN"
					MENU SELECT_DIR_N "$2" "$3" "$4" "" "$6"
				fi
				if [[ "$RUN" == "[Select_this_dir]" ]]
				then
					$RUN
				fi
				if [[ "$RUN" == "[MKDIR]" ]]
				then
					$RUN
					MENU SELECT_DIR_N "$2" "$3" "$4" "" "$6"
				fi
				;;
				*)
				exit "$?"
				;;
			esac
		fi
	;;
	SELECT_FILE)
		CDDIR "$5"
		if [[ "$6" != "" ]]
		then
			export ARG
			local m=0 n=1
			for A in "$@"
			do
				if (( $m >= 5 ))
				then
					if [[ "$A" != '--up' ]]
					then
						ARG[$n]="$A"
						((n++))
					else
						export ADT="$A"
					fi
				fi
				((m++))
			done
			unset m n A
		fi
		CD "$dir" "$ADT"
		FILELIST_ALL
		for A in ${ARG[@]}
		do
			FILELIST_FILE "$A"
		done
		FILELIST_ONLY_DIRS
		case "$INTERFACE" in
			dialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			Xdialog)
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 $(( ${#files[@]} / 2 + 1 ))"
			;;
			whiptail)
				SIZE="0 0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="$(( ${#files[@]} / 2 + 7 )) 0 ${#files[@]}"
			;;
			*)
				SIZE="0 0 0"
			;;
		esac
		if [[ "${files[@]}" != "" ]]
		then
			RUN=$($INTERFACE --backtitle "$4" --title "$3" --menu "$2" $SIZE "${files[@]}" 3>&1 1>&2 2>&3)
			case $? in
				0)
				if [[ `file "$RUN"` == *': directory'* || `file "$RUN"` == *', directory'* ]]
				then
					cd "$RUN"
					MENU SELECT_FILE "$2" "$3" "$4" "" ""
				else
					echo `realpath --relative-to="$DIR" "$RUN"`
				fi
				;;
				*)
					exit "$?"
				;;
			esac
		else
			$INTERFACE --title  "Error" --msgbox  "The directory is empty" 0 0  3>&1 1>&2 2>&3
			exit 255
		fi
	;;
	MKFILE)
		case "$INTERFACE" in
			dialog)
				SIZE="7 70"
			;;
			Xdialog)
				SIZE="8 70"
			;;
			whiptail)
				SIZE="0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="7 70"
			;;
			*)
				SIZE="0 0"
			;;
		esac
		RUN=$($INTERFACE --backtitle "$3" --title "MKFILE" --inputbox "$2" $SIZE 3>&1 1>&2 2>&3)
		case $? in
			0)
				$TEXTEDITOR "$RUN"
			;;
		esac
	;;
	MKDIR)
		case "$INTERFACE" in
			dialog)
				SIZE="7 70"
			;;
			Xdialog)
				SIZE="8 70"
			;;
			whiptail)
				SIZE="0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="7 70"
			;;
			*)
				SIZE="0 0"
			;;
		esac
		RUN=$($INTERFACE --backtitle "$3" --title "MKDIR" --inputbox "$2" $SIZE 3>&1 1>&2 2>&3)
		case $? in
			0)
				INFO=$(mkdir "$RUN" 3>&1 1>&2 2>&3)
				if [[ $? != 0 ]]
				then
					$INTERFACE --title "Error" --msgbox "$INFO" 0 0 3>&1 1>&2 2>&3
				else
					cd "$RUN"
				fi
			;;
		esac
	;;
	RM)
		FILELIST_ALL
		FILELIST
		case "$INTERFACE" in
			dialog)
				SIZE="$(( ${#files[@]} / 2 + 6 )) 0 ${#files[@]}"
			;;
			Xdialog)
				SIZE="0 0 $(( ${#files[@]} / 2 + 2 ))"
			;;
			whiptail)
				SIZE="0 0 0"
			;;
			'')
				INTERFACE="dialog"
				SIZE="$(( ${#files[@]} / 2 + 6 )) 0 ${#files[@]}"
			;;
			*)
				SIZE="0 0 0"
			;;
		esac
		RUN=$($INTERFACE --backtitle "$3" --title "RM" --menu "$2" $SIZE "${files[@]}" 3>&1 1>&2 2>&3)
		case $? in
			0)
				INFO=$(rm -r "$RUN" 3>&1 1>&2 2>&3)
				if [[ $? != 0 ]]
				then
					$INTERFACE --title  "Error" --msgbox  "$INFO" 0 0 3>&1 1>&2 2>&3
				fi
			;;
		esac
	;;
	esac
}
#--Кнопки в меню------------------------------------------------------------------------------
[Select_this_dir](){
	echo "`realpath --relative-to="$DIR" ./`"
}

[MKFILE](){
MENU MKFILE
}

[MKDIR](){
MENU MKDIR
}
[DELETE](){
MENU RM 
}

..() {
	cd ../
}

CD() {
if [[ "$2" == '--up' ]]
then
	files[i]=".."
	files[i+1]=""
	((i+=2))
	((s++))
else
	if [[ "$1" != `pwd` ]]
	then
		files[i]=".."
		files[i+1]=""
		((i+=2))
		((s++))
	fi
fi
}
#----------------------------------------------------------------------------------------------
FILELIST_ALL()
{
	local i=0
	for f in *
	do
		if [[ "$f" != '*' ]]
		then
			ALL[i]="$f"
			((i++))
		fi
	done
}
FILELIST()
{
	for ((X=0; X < "${#ALL[@]}"; X++))
	do
		files[i]="${ALL[$X]}"
		files[i+1]=""
		((i+=2))
		((s++))
	done
}
FILELIST_ONLY_DIRS()
{
	Z="`DIRS_FIND`"
	SORT `sort -r <<< "$Z"`
}
FILELIST_OBJECT()
{
	Z="`OBJECT_FIND "$1" "$2"`"
	SORT "`sort -g <<< "$Z"`"
}
FILELIST_FILE()
{
	for ((X=0; X < "${#ALL[@]}"; X++))
	do
		if [[ "${ALL[$X]}" == $1 ]]
		then
			files[i]="${ALL[$X]}"
			files[i+1]=""
			((i+=2))
			((s++))
		fi
	done
}
#----------------------------------------------------------------------------------------------
DIRS_FIND()
{
	for ((X=0; X < "${#ALL[@]}"; X++))
	do
		DIRS "${ALL[$X]}" &
	done
	wait
}
DIRS()
{
	if [[ "$1" != '*' ]]
	then
		local U=`file "$1"`
		if [[ "$U" == *': directory'*  || "$U" == *', directory'* ]]
		then
			U=${1/ /~%%%}
			echo -en "$U\n"
		fi
	fi
}
#----------------------------------------------------------------------------------------------
OBJECT_FIND()
{
	for ((X=0; X < "${#ALL[@]}"; X++))
	do
		if [[ "${ALL[$X]}" == *$1* && "${ALL[$X]}" == *$2* ]]
		then
			#Отрезаем $1 и $2 из файла
			U="${ALL[$X]}"
			U="${U##*$1}"
			echo -en "${U%$2}\n"
		fi
	done
}
#----------------------------------------------------------------------------------------------
SORT()
{
	local sort n
	sort=( $@ )
	for ((X=0; X < "${#sort[@]}"; X++))
	do
		sort[$X]="${sort[$X]/~%%%/ }"
	done
	n="${#sort[@]}"
	((n--))
	while (( -1 != $n ))
	do
		files[i]="${sort[$n]}"
		files[i+1]=""
		((i+=2))
		((n--))
	done
}
CDDIR()
{
	if [[ "$1" != "" ]]
	then
		cd "$1"
		EXIT $?
		export dir=`pwd`
	fi
}
EXIT()
{
if [[ $1 != 0 ]]
then
	echo "ERROR $1"
	exit $1
fi
}
WORKDIR()
{
if [[ $1 != "" ]]
then
	cd "$1"
	EXIT $?
	export DIR=`readlink -e "$1"`
else
	export DIR=`readlink -e "./"`
fi
}