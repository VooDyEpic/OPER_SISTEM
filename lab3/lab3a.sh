
if [ -z "$1" ]; then
    echo "Ошибка: Укажите путь к папке с фотографиями"
    echo "Пример использования: $0 /путь/к/папке"
    exit 1
fi

SOURCE_DIR="$1"
PARENT_DIR=$(dirname "$SOURCE_DIR")
FOLDER_NAME=$(basename "$SOURCE_DIR")
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="${FOLDER_NAME}_backup_${TIMESTAMP}"
BACKUP_PATH="${PARENT_DIR}/${BACKUP_NAME}"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: Папка $SOURCE_DIR не существует"
    exit 1
fi

echo "Создаю резервную папку: $BACKUP_PATH"
mkdir -p "$BACKUP_PATH" || {
    echo "Ошибка создания папки для резервной копии"
    exit 1
}

echo "Начинаю копирование фотографий..."
COUNTER=0

find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.heic" \) -exec cp -vp -- "{}" "$BACKUP_PATH" \; | while read -r line; do
    echo "Скопировано: $line"
    ((COUNTER++))
done

if [ $COUNTER -eq 0 ]; then
    echo "Внимание: Не найдено ни одной фотографии для копирования!"
    rmdir "$BACKUP_PATH"
    exit 1
else
    echo "Успешно скопировано файлов: $COUNTER"
    echo "Резервная копия создана в: $BACKUP_PATH"
fi

exit 0