CC = gcc                     # Компилятор: gcc
CFLAGS = -Wall -Wextra -O2   # Флаги: все предупреждения, доп. предупреждения, оптимизация O2
TARGET = factorial_program   # Имя итогового исполняемого файла
OBJS = main.o factorial.o    # Список объектных файлов

all: $(TARGET)               # Цель по умолчанию: собрать программу

$(TARGET): $(OBJS)           # Исполняемый файл зависит от объектных файлов
	$(CC) $(CFLAGS) -o $@ $^ # Сборка: $@ = цель, $^ = все зависимости

main.o: main.c factorial.h   # main.o зависит от main.c и factorial.h
	$(CC) $(CFLAGS) -c main.c # Компиляция main.c в main.o

factorial.o: factorial.c factorial.h # factorial.o зависит от .c и .h
	$(CC) $(CFLAGS) -c factorial.c  # Компиляция factorial.c в factorial.o

run: $(TARGET)               # Цель запуска: требует собранную программу
	./$(TARGET)              # Запуск программы

clean:                       # Цель очистки: удалить объектники и исполняемый файл
	rm -f $(OBJS) $(TARGET)

# Ассемблерные файлы
asm:                         # Сгенерировать ассемблер с оптимизацией по умолчанию (O2)
	$(CC) -S main.c -o main.s
	$(CC) -S factorial.c -o factorial.s

asm-O0:                      # Сгенерировать ассемблер без оптимизации (-O0)
	$(CC) -S main.c -o main_O0.s -O0
	$(CC) -S factorial.c -o factorial_O0.s -O0

asm-O2:                      # Сгенерировать ассемблер с оптимизацией -O2
	$(CC) -S main.c -o main_O2.s -O2
	$(CC) -S factorial.c -o factorial_O2.s -O2

asm-O3:                      # Сгенерировать ассемблер с оптимизацией -O3
	$(CC) -S main.c -o main_O3.s -O3
	$(CC) -S factorial.c -o factorial_O3.s -O3

clean-asm:                   # Удалить все сгенерированные .s файлы
	rm -f *.s

clean-all: clean clean-asm   # Полная очистка: объектники, программу, ассемблер, result.txt
	rm -f result.txt

.PHONY: all run clean asm asm-O0 asm-O2 asm-O3 clean-asm clean-all  # Фиктивные цели (не файлы)