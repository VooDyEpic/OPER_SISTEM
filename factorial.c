#include "factorial.h"
#include <stdio.h>
#include <stdlib.h>

// Вычисление факториала (итеративно - так лучше видно цикл в ассемблере)
unsigned long long factorial(int n) {
    unsigned long long result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// Запись результата в файл (общий ресурс)
void write_result_to_file(const char* filename, int n, unsigned long long result) {
    FILE* file = fopen(filename, "w");
    if (file == NULL) {
        perror("fopen for write failed");
        return;
    }
    fprintf(file, "%d %llu\n", n, result);
    fclose(file);
    printf("[FILE_WRITE] %s записан\n", filename);
}

// Чтение результата из файла
int read_result_from_file(const char* filename, unsigned long long* result) {
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        perror("fopen for read failed");
        return -1;
    }
    int n;
    fscanf(file, "%d %llu", &n, result);
    fclose(file);
    printf("[FILE_READ] %s прочитан\n", filename);
    return 0;
}