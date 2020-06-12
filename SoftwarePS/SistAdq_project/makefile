# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

CC = gcc                        # compiler to use

LINKERFLAG = -lm -lrt -pthread

SRC_SRCS := $(wildcard src/*.c) 
SRC_HEADERS := $(wildcard src/*.h) 
LIB_SRCS := $(wildcard lib/*.c)
LIB_HEADERS := $(wildcard lib/*.h)

.PHONY: all clean

all: SistAdq

SistAdq: $(SRC_SRCS) $(SRC_HEADERS) $(LIB_SRCS) $(LIB_HEADERS) main.c
	gcc -g -Wall main.c $(SRC_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

clean:
	rm -rvf SistAdq