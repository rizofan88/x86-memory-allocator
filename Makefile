AS = as
LD = ld

ASFLAGS = --32 -Iinclude
LDFLAGS = -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc
SO_LDFLAGS = -m elf_i386 -shared -lc

BUILD_DIR = build

LIB_TARGET = $(BUILD_DIR)/liballocator.so
DEMO_TARGET = $(BUILD_DIR)/demo_exec

UNIT_TEST_TARGET = $(BUILD_DIR)/test_unit_exec
INTEGRATION_TEST_TARGET = $(BUILD_DIR)/test_integration_exec

DEMO_SRC = src/test_mem.s

CORE_SRC = src/allocator.s \
		   src/deallocate.s \
		   src/deallocate_check.s \
		   src/exit_with_error.s \
		   src/extend_break.s \
		   src/mark_ptr.s \
		   src/return_bin_info.s \
		   src/scan_memory.s \
		   src/update_pointer.s \
		   src/debug/debug.s \
		   src/debug/init_debug.s \
		   src/print/print_data.s \
		   src/print/print_data_title.s \
		   src/print/print_functions.s

UNIT_TEST_SRC = test/test_unit.s \
				test/run_test.s \
				test/print_status.s \
				test/redirect.s \
				$(wildcard test/unit/test_*.s)

INTEGRATION_TEST_SRC = test/test_integration.s \
					   test/run_test.s \
					   test/print_status.s \
					   test/redirect.s \
					   $(wildcard test/integration/test_*.s)

CORE_OBJ = $(CORE_SRC:src/%.s=$(BUILD_DIR)/%.o)
DEMO_OBJ = $(DEMO_SRC:src/%.s=$(BUILD_DIR)/%.o)

UNIT_TEST_OBJ = $(UNIT_TEST_SRC:test/%.s=$(BUILD_DIR)/test/%.o)
INTEGRATION_TEST_OBJ = $(INTEGRATION_TEST_SRC:test/%.s=$(BUILD_DIR)/test/%.o)

all: $(LIB_TARGET)

$(LIB_TARGET): $(CORE_OBJ)
	$(LD) $(SO_LDFLAGS) -o $@ $^

$(DEMO_TARGET): $(DEMO_OBJ) $(LIB_TARGET)
	$(LD) $(LDFLAGS) -L$(BUILD_DIR) -o $@ $(DEMO_OBJ) -lallocator

$(UNIT_TEST_TARGET): $(UNIT_TEST_OBJ) $(CORE_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(INTEGRATION_TEST_TARGET): $(INTEGRATION_TEST_OBJ) $(CORE_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: src/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/test/%.o: test/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

demo: $(DEMO_TARGET)
	LD_LIBRARY_PATH=$(BUILD_DIR) $(DEMO_TARGET)

test: test-unit test-integration

test-unit: $(UNIT_TEST_TARGET)
	$(UNIT_TEST_TARGET)

test-integration: $(INTEGRATION_TEST_TARGET)
	$(INTEGRATION_TEST_TARGET)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean demo test test-unit test-integration
