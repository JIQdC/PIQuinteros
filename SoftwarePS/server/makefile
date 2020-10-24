# Emulation, acquisition and data processing system for sensor matrices
# José Quinteros del Castillo
# Instituto Balseiro
# ---
# Makefile for server functions

# Version: 2020-10-24
# Comments:

# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

CC = gcc                        # compiler to use

LINKERFLAG = -lm -lrt -pthread

SERVER_SRCS := $(wildcard src/*.c) 
SERVER_SRCS := $(filter-out fileReader.c, $(SERVER_SRCS))
SERVER_HEADERS := $(wildcard src/*.h) 
LIB_SRCS := $(wildcard ../SistAdq_project/lib/*.c)
LIB_HEADERS := $(wildcard ../SistAdq_project/lib/*.h)

.PHONY: all clean

all: server_main fileReader

server_main: server_main.c $(SERVER_SRCS) $(SERVER_HEADERS) $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall server_main.c $(SERVER_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

fileReader: fileReader.c $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall fileReader.c $(LIB_SRCS) -o $@ $(LINKERFLAG)

clean:
	rm -rvf server_main fileReader