#ifndef FACTORIAL_H
#define FACTORIAL_H

unsigned long long factorial(int n);
// Функция для записи результата в файл
void write_result_to_file(const char* filename, int n, unsigned long long result);

// Функция для чтения результата из файла
int read_result_from_file(const char* filename, unsigned long long* result);
#endif