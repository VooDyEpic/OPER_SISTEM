# Лаба 1
написал код на С факториал числа
```
#include "factorial.h"
unsigned long long factorial(int n) {
    unsigned long long result = 1;
    for (int i = 2; i <= n; i++)
        result *= i;
    return result;
}
```

взято из factorial.c
Транслирую программу в Assembler с разными опциями оптимизации помощью команд:

gcc -S -O0 -o factorialO0.s factorial.c     -Без оптимизации
gcc -S -O1 -o factorialO1.s factorial.c     -Базовая оптимизация
gcc -S -O2 -o factorialO2.s factorial.c     -Средняя оптимизация
gcc -S -O3 -o factorialO3.s factorial.c     -Агрессивная оптимизация
gcc -S -Os -o factorialOs.s factorial.c     -Оптимизация по размеру кода
# 2 шаг
main00 был разобран для задания и было указано циклы и тд.

Полный код с оптимизацией O0 и разбором:
```
; === МЕТАДАННЫЕ ИСХОДНОГО ФАЙЛА ===
.file	"main.c"              ; имя исходного C-файла
.text                         ; секция кода (text segment)

; === ФУНКЦИЯ factorial (рекурсивная реализация) ===
.globl	factorial             ; сделать функцию видимой для линковщика
.def	factorial;	.scl	2;	.type	32;	.endef  ; метаданные для Windows
.seh_proc	factorial         ; начало обработки исключений Windows x64

factorial:
	; === ПРОЛОГ ФУНКЦИИ (создание stack frame) ===
	pushq	%rbp              ; сохранить старый базовый указатель
	.seh_pushreg	%rbp      ; информация для раскрутки стека
	movq	%rsp, %rbp        ; установить новый frame: RBP = RSP
	.seh_setframe	%rbp, 0
	subq	$32, %rsp         ; выделить 32 байта в стеке для локальных переменных
	.seh_stackalloc	32
	.seh_endprologue          ; конец пролога

	; === ТЕЛО ФУНКЦИИ ===
	movl	%ecx, 16(%rbp)    ; сохранить аргумент n (ECX) в стеке по адресу RBP+16
	                          ; n = первый параметр функции (по соглашению Windows x64 параметры передаются в ECX/RCX)
	
	cmpl	$1, 16(%rbp)      ; сравнить n с 1
	jg	.L2                   ; если n > 1, перейти к .L2 (рекурсивный случай)
	
	; === БАЗОВЫЙ СЛУЧАЙ: n <= 1 ===
	movl	$1, %eax           ; вернуть 1 (результат в EAX)
	jmp	.L3                   ; перейти к эпилогу функции
	
.L2:
	; === РЕКУРСИВНЫЙ СЛУЧАЙ: n > 1 ===
	movl	16(%rbp), %eax     ; загрузить n в EAX
	subl	$1, %eax           ; EAX = n - 1
	movl	%eax, %ecx         ; подготовить аргумент для рекурсивного вызова: ECX = n-1
	call	factorial          ; рекурсивный вызов factorial(n-1)
	                          ; результат предыдущего вызова возвращается в EAX
	imull	16(%rbp), %eax     ; EAX = EAX * n = factorial(n-1) * n
	
.L3:
	; === ЭПИЛОГ ФУНКЦИИ (восстановление стека) ===
	addq	$32, %rsp         ; освободить локальный стек (32 байта)
	popq	%rbp              ; восстановить старый RBP
	ret                       ; вернуться к вызывающей функции
	
	.seh_endproc              ; конец обработки исключений

; === СЕКЦИЯ ДАННЫХ (readonly data) ===
	.section .rdata,"dr"      ; секция только для чтения
.LC0:
	.ascii "%d\0"             ; строка формата для printf (без вывода \n)

; === ФУНКЦИЯ main ===
	.text
.globl	main
.def	main;	.scl	2;	.type	32;	.endef
.seh_proc	main

main:
	; === ПРОЛОГ main ===
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	
	call	__main            ; инициализация C runtime (MinGW специфика)
	
	; === ТЕЛО main ===
	movl	$7, %ecx          ; передать аргумент n=7 в функцию factorial (через ECX)
	call	factorial         ; вычислить factorial(7)
	                          ; результат возвращается в EAX
	
	movl	%eax, %edx        ; второй аргумент для printf: EDX = результат factorial
	leaq	.LC0(%rip), %rax  ; загрузить адрес строки формата "%d" в RAX
	movq	%rax, %rcx        ; первый аргумент для printf: RCX = форматная строка
	call	printf            ; вывести результат
	
	movl	$0, %eax          ; вернуть 0 из main (успешное завершение)
	
	; === ЭПИЛОГ main ===
	addq	$32, %rsp
	popq	%rbp
	ret
	
	.seh_endproc

; === ССЫЛКИ НА ВНЕШНИЕ ФУНКЦИИ ===
.def	__main;	.scl	2;	.type	32;	.endef
.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"
.def	printf;	.scl	2;	.type	32;	.endef
```

# шаг 3
структура проекта:
```проект/
├── Makefile          
├── main.c            # программа с fork()/pipe()
├── factorial.c       # реализация factorial()
└── factorial.h       # заголовочный файл
```
Makefile
```
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
```
Параллельный процесс:

Используется системный вызов fork() для создания дочернего процесса.
Родительский процесс вычисляет факториал числа (например, 7) и записывает результат в разделяемую память.
Дочерний процесс читает результат из разделяемой памяти и выводит его.
Разделяемая память:

Создаётся сегмент разделяемой памяти с помощью shmget и подключается через shmat.
Размер памяти равен sizeof(int) для хранения результата факториала.
Ключ для памяти генерируется с помощью ftok на основе текущей директории.
Синхронизация:

Для предотвращения одновременного доступа к разделяемой памяти используется именованный POSIX-семафор (sem_open, sem_wait, sem_post).
Семафор инициализируется со значением 1, обеспечивая взаимоисключающий доступ (mutex).
Родительский процесс захватывает семафор перед записью, а дочерний — перед чтением.
Обработка сигналов и очистка:

Регистрируются обработчики сигналов (SIGINT, SIGTERM) для корректного освобождения ресурсов (разделяемой памяти и семафора) при прерывании программы.
Функция cleanup отсоединяет и удаляет разделяемую память, закрывает и удаляет семафор.


# LAB 2 https://drive.google.com/drive/folders/1HsgNtDyqvx2RNVIrjLb9Hetow79YDhBO?dmr=1&ec=wgc-drive-%5Bmodule%5D-goto
