CC := gcc
CFLAGS := -Wall -Werror -Wextra -pedantic -Iinclude -fPIC
LDFLAGS := -shared

SRC_DIR := src
LIB_DIR := lib
BUILD_DIR := build
TEST_DIR := tests
TEST_SRC := $(TEST_DIR)/test_spindler.c
TEST_BIN := $(BUILD_DIR)/test

SRC := $(filter-out $(TEST_SRC), $(wildcard $(SRC_DIR)/*.c))

.PHONY: all clean test

all: $(LIB_DIR)/libspindler.so

$(LIB_DIR)/libspindler.so: $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -lrinterpolate

test: $(TEST_BIN) $(LIB_DIR)/libspindler.so
	export LD_LIBRARY_PATH=$(LIB_DIR) && ./$(TEST_BIN)

$(TEST_BIN): $(TEST_SRC) $(LIB_DIR)/libspindler.so
	$(CC) $(CFLAGS) -o $@ $< -L$(LIB_DIR) -lrinterpolate -lspindler

clean:
	$(RM) $(LIB_DIR)/libspindler.so $(BUILD_DIR)/*
