# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

CC = gcc                        # compiler to use

LINKERFLAG = -lm -lrt -pthread

CLIENT_SRCS := $(wildcard client/*.c) 
CLIENT_HEADERS := $(wildcard client/*.h) 
SERVER_SRCS := $(wildcard server/*.c) 
SERVER_HEADERS := $(wildcard server/*.h) 
LIB_SRCS := $(wildcard lib/*.c)
LIB_HEADERS := $(wildcard lib/*.h)

.PHONY: all clean

all: client_main server_main

client_main: $(CLIENT_SRCS) $(CLIENT_HEADERS) $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall $(CLIENT_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

server_main: $(SERVER_SRCS) $(SERVER_HEADERS) $(LIB_SRCS) $(LIB_HEADERS)
	gcc -g -Wall $(SERVER_SRCS) $(LIB_SRCS) -o $@ $(LINKERFLAG)

clean:
	rm -rvf client_main server_main