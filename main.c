#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>      // fork(), pipe(), read(), write()
#include <string.h>      // memcpy()
#include "factorial.h"

#define BUFFER_SIZE 256

// Имя файла-общего ресурса
const char* SHARED_FILE = "result.txt";

int main() {
    int pipe_fd[2];          // pipe_fd[0] - чтение, pipe_fd[1] - запись
    pid_t pid;
    int n = 7;               // число для вычисления факториала
    char buffer[BUFFER_SIZE];
    unsigned long long result;
    int bytes_read;

    // 1. СОЗДАНИЕ ПАЙПА (канала связи между процессами)
    if (pipe(pipe_fd) == -1) {
        perror("pipe creation failed");
        exit(EXIT_FAILURE);
    }

    // 2. СОЗДАНИЕ ДОЧЕРНЕГО ПРОЦЕССА
    pid = fork();

    if (pid == -1) {
        perror("fork failed");
        exit(EXIT_FAILURE);
    }

    // ========== ДОЧЕРНИЙ ПРОЦЕСС (ЧИСЛИТЕЛЬ) ==========
    if (pid == 0) {
        // Дочерний процесс будет вычислять факториал
        close(pipe_fd[0]);   // закрываем чтение из пайпа (будем только писать)

        printf("[CHILD] PID=%d, вычисляю factorial(%d)...\n", getpid(), n);
        
        // Вычисляем факториал
        result = factorial(n);
        
        printf("[CHILD] Результат: %llu\n", result);
        
        // ЗАПИСЬ В ОБЩИЙ РЕСУРС (ФАЙЛ)
        write_result_to_file(SHARED_FILE, n, result);
        printf("[CHILD] Результат записан в файл %s\n", SHARED_FILE);
        
        // Отправляем результат родителю через пайп
        snprintf(buffer, BUFFER_SIZE, "%llu", result);
        write(pipe_fd[1], buffer, strlen(buffer) + 1);
        printf("[CHILD] Результат отправлен родителю через pipe\n");
        
        close(pipe_fd[1]);   // закрываем запись
        exit(EXIT_SUCCESS);   // завершаем дочерний процесс
    }
    
    // ========== РОДИТЕЛЬСКИЙ ПРОЦЕСС ==========
    else {
        close(pipe_fd[1]);   // закрываем запись в пайп (будем только читать)
        
        printf("[PARENT] PID=%d, ожидаю результат от дочернего процесса...\n", getpid());
        
        // 3. СИНХРОНИЗАЦИЯ: ожидаем завершения дочернего процесса
        wait(NULL);
        
        // Читаем результат из пайпа
        bytes_read = read(pipe_fd[0], buffer, BUFFER_SIZE);
        if (bytes_read > 0) {
            printf("[PARENT] Получено из pipe: %s\n", buffer);
        }
        close(pipe_fd[0]);
        
        // 4. ЧТЕНИЕ ИЗ ОБЩЕГО РЕСУРСА (ФАЙЛА) с проверкой синхронизации
        //    (файл был записан дочерним процессом, и родитель ждал wait())
        if (read_result_from_file(SHARED_FILE, &result) == 0) {
            printf("[PARENT] Прочитано из файла: factorial(%d) = %llu\n", n, result);
        } else {
            printf("[PARENT] Не удалось прочитать файл\n");
        }
        
        printf("[PARENT] Завершение работы\n");
    }
    
    return 0;
}