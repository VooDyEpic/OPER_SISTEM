CC = gcc
CFLAGS = -Wall -O2
TARGET = factorial
OBJS = main.o factorial.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

main.o: main.c factorial.h
	$(CC) $(CFLAGS) -c main.c

factorial.o: factorial.c factorial.h
	$(CC) $(CFLAGS) -c factorial.c

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean