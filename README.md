# libbashmenu
Библиотека для построения интерфейсов


HELP

Выводит этот текст помощи.


MENU SELECT_FILE

Меню выбора файла.
Если oпция опция '--up' передана, всегда отображается переход к верхней папке.
MENU SELECT_FILE	"Текст внутри окна" "Текст в шапке окна" "Текст на заднем фоне" [папка в которой откроется меню] '*.config' --up


MENU FIND_OBJECT

Меню выбора файла, отображает только содержимое между аргументами.
MENU FIND_OBJECT	"Текст внутри окна" "Текст в шапке окна" "Текст на заднем фоне" [папка в которой откроется меню] '.ckpt-' '.meta' --up


MENU SELECT_DIR_N

Меню выбора папки.


MENU SELECT_DIR_N	"Текст внутри окна" "Текст в шапке окна" "Текст на заднем фоне" [папка в которой откроется меню] --up
WORKDIR

Переменная INTERFACE позволяет указать программу для отображения окон. dialog, Xdialog, whiptail и т.д.


MENU MKFILE

Меню создания файла, использует редактор из переменной TEXTEDITOR.


MENU MKDIR

Меню создания папки.


MENU RM

Меню удаления.


WORKDIR

Меняет рабочий каталог и записывает полный путь к нему в глобальной переменной 'DIR'. Обязательна для работы меню.


EXIT

Выполняет команду exit, если код завершения не равен нулю.
