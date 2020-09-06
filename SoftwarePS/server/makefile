# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

CC = gcc                        # compiler to use

LINKERFLAG = -lm -lrt -pthread

SERVER_SRCS := $(wildcard *.c) 
SERVER_SRCS := $(filter-out fileReader.c, $(SERVER_SRCS))
SERVER_HEADERS := $(wildcard *.h) 
LIB_SRCS := $(wildcard ../SistAdq_project/lib/*.c)
LIB_HEADERS := $(wildcard ../SistAdq_project/lib/*.h)
SRC_SRCS := $(wildcard ../SistAdq_project/src/*.c)
SRC_HEADERS := $(wildcard ../SistAdq_project/src/*.h)

.PHONY: all clean

all: server_main fileReader

server_main: $(SERVER_SRCS) $(SERVER_HEADERS) $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall $(SERVER_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

fileReader: fileReader.c $(SRC_SRCS) $(SRC_HEADERS) $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall fileReader.c $(SRC_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

clean:
	rm -rvf server_main