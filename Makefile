TARGET_EXEC ?= myprogram   # Main program executable
TARGET_LAB ?= build/lab          # Additional lab executable
TARGET_TEST ?= build/test-lab    # Test executable

UNAME_S := $(shell uname -s)
BUILD_DIR ?= build
TEST_DIR ?= tests
SRC_DIR ?= src
EXE_DIR ?= app

SRCS := $(shell find $(SRC_DIR) -name *.c)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

TEST_SRCS := $(shell find $(TEST_DIR) -name *.c)
TEST_OBJS := $(TEST_SRCS:%=$(BUILD_DIR)/%.o)
TEST_DEPS := $(TEST_OBJS:.o=.d)

EXE_SRCS := $(shell find $(EXE_DIR) -name *.c)
EXE_OBJS := $(EXE_SRCS:%=$(BUILD_DIR)/%.o)
EXE_DEPS := $(EXE_OBJS:.o=.d)

CFLAGS ?= -Wall -Wextra -fno-omit-frame-pointer -fsanitize=address -g -MMD -MP
LDFLAGS ?= -pthread -lreadline

# Default target to build all executables
all: $(TARGET_EXEC) $(TARGET_LAB) $(TARGET_TEST)

# Compile main executable (myprogram)
$(TARGET_EXEC): $(OBJS) $(EXE_OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(EXE_OBJS) -o $(TARGET_EXEC) $(LDFLAGS)

# Compile additional lab executable (lab)
$(TARGET_LAB): $(OBJS) $(EXE_OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(EXE_OBJS) -o $(TARGET_LAB) $(LDFLAGS)

# Compile test executable
$(TARGET_TEST): $(OBJS) $(TEST_OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(TEST_OBJS) -o $(TARGET_TEST) $(LDFLAGS)

# Rule to compile object files
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Run tests
check: $(TARGET_TEST)
ifeq ($(UNAME_S),Linux)
	ASAN_OPTIONS=detect_leaks=1 ./$<
else
	./$<
endif

# Clean up build files
.PHONY: clean
clean:
	$(RM) -rf $(BUILD_DIR) $(TARGET_EXEC) $(TARGET_LAB) $(TARGET_TEST)

# Install dependencies on Codespaces
.PHONY: install-deps
install-deps:
	sudo apt-get update -y
	sudo apt-get install -y libio-socket-ssl-perl libmime-tools-perl

# Include dependency files for incremental builds
-include $(DEPS) $(TEST_DEPS) $(EXE_DEPS)
