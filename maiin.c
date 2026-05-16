#include <stdio.h>

unsigned long long factorial(int n) {
    unsigned long long result = 1;
    for (int i = 2; i <= n; i++)
        result *= i;
    return result;
}

int main() {
    int n = 5;
    printf("Factorial of %d = %llu\n", n, factorial(n));
    return 0;
}