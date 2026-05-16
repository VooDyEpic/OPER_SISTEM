# Лаба 1
написал код на С факториал числа
```c
#include "factorial.h"
unsigned long long factorial(int n) {
    unsigned long long result = 1;
    for (int i = 2; i <= n; i++)
        result *= i;
    return result;
}```

взято из factorial.c
Транслирую программу в Assembler с разными опциями оптимизации помощью команд:

gcc -S -O0 -o factorialO0.s factorial.c     -Без оптимизации
gcc -S -O1 -o factorialO1.s factorial.c     -Базовая оптимизация
gcc -S -O2 -o factorialO2.s factorial.c     -Средняя оптимизация
gcc -S -O3 -o factorialO3.s factorial.c     -Агрессивная оптимизация
gcc -S -Os -o factorialOs.s factorial.c     -Оптимизация по размеру кода
# 2 шаг
main00 был разобран для задания и было указано циклы и тд.

Полный код с оптимизацией O0 доступен в файле:  
#шаг 3
структура проекта:
проект/
├── Makefile          # этот файл
├── main.c            # программа с fork()/pipe()
├── factorial.c       # реализация factorial()
└── factorial.h       # заголовочный файл

