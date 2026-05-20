passed:
    .ascii "PASSED: %s\n\n\0"
failed_str:
    .ascii "FAILED: %s\n\n\0"
test_str:
    .ascii "TEST: %s\n\0"
fork_fail:
.ascii "Forking failed\n\0"

.equ TEST_PASS, 0
.equ TEST_FAIL, 1

.equ TEST_ERR_CODE, 128

.equ EXPECT_SUCCESS, 0
.equ EXPECT_FAILURE, 1

test_allocate_init_str:
    .ascii "test_allocate_init\0"

test_allocate_str:
    .ascii "test_allocate\0"

test_update_break_str:
    .ascii "test_update_break\0"

test_return_heap_begin_and_end_str:
    .ascii "test_return_heap_begin_and_end_str\0"

test_deallocate_str:
    .ascii "test_deallocate\0"

test_deallocate_check_str:
    .ascii "test_deallocate_check\0"

test_exit_with_error_str:
    .ascii "test_exit_with_error\0"
    
test_extend_break_str:
    .ascii "test_extend_break\0"
    
test_mark_ptr_str:
    .ascii "test_mark_ptr\0"

test_return_bin_info_str:
    .ascii "test_return_bin_info\0"
    
test_scan_memory_str:
    .ascii "test_scan_memory\0"    

test_update_new_pointer_str:
    .ascii "test_update_new_pointer\0"

test_allocate_and_deallocate_str:
    .ascii "test_allocate_and_deallocate\0"

test_memory_write_and_read_str:
    .ascii "test_memory_write_and_read\0"

test_valid_heap_growth_str:
    .ascii "test_valid_heap_growth\0"
