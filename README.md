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
