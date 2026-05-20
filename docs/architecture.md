# Architecture

The allocator is divided into three main public entry points:

* `allocator.s`: exposes the `allocate()` function and allocation helpers
* `deallocate.s`: exposes the `deallocate()` function
* `debug.s`: exposes the `debug()` function, which prints the current heap state

All remaining source files inside `src/` are internal helpers used by these public functions and are not intended to be called directly by the user.

## Execution Model

The allocator manages heap memory using the Linux `brk` syscall.

The execution flow begins when the user requests memory through `allocate()`.

On the first allocation request, the allocator initializes its internal heap state by storing:

* `heap_begin`
* `current_break`

These values are retrieved by querying the current program break from the kernel.

After initialization, the allocator rounds the requested allocation size into one of the following fixed-size bins:

* 16 bytes
* 32 bytes
* 64 bytes
* 128 bytes

Requests larger than 128 bytes are handled through a general-purpose "big" bin.

Once the correct bin has been selected, the allocator scans the linked list associated with that bin looking for an available block.

If an available block is found:

* the block is marked as used
* the payload address is returned to the caller

If no suitable block exists:

* the allocator extends the heap using `brk`
* a new block is initialized
* the block is linked into the correct bin list
* the payload address is returned

The `deallocate()` function marks a previously allocated block as available so it can later be reused.

The `debug()` function walks through heap memory linearly and prints:

* block state
* header address
* payload boundaries
* block size
* previous and next pointers

This provides a live visualization of allocator state.

---

# Heap Initialization

The allocator lazily initializes heap state.

When `allocate()` is called for the first time, it internally calls `allocate_init()`.

This function:

1. queries the current program break using `brk(0)`
2. stores the returned address in `heap_begin`
3. stores the same address in `current_break`

This assumes the allocator owns heap growth starting from the current process break.

---

# Allocation Size Rounding

Allocation requests are rounded into fixed-size bins to simplify reuse and reduce traversal overhead.

The allocator currently supports the following bins:

* 16-byte bin
* 32-byte bin
* 64-byte bin
* 128-byte bin
* big bin (larger than 128 bytes)

The allocator compares the requested size against these bin sizes and selects the smallest valid bin.

For fixed-size bins:

* the rounded bin size is returned internally
* allocations reuse blocks of the same bin size

For large allocations:

* the original requested size is preserved
* the allocation is handled through the general-purpose big bin

The allocator also tracks:

* the head pointer of the selected bin
* the address of the bin head variable

This allows new blocks to initialize empty bin lists when necessary.

---

# Memory Layout

Each allocated block contains a header followed by its payload.

The header stores:

* allocation state (free or used)
* block size
* previous block pointer within the same bin
* next block pointer within the same bin

The payload immediately follows the header.

This layout allows the allocator to traverse allocations through linked lists instead of performing a full linear heap scan for every request.

---

# Scanning Through Memory

The allocator scans memory through the linked list associated with the selected bin.

The start point is always the address stored in the selected bin, which represents the head pointer of linked-list.

During traversal:

* each block header is checked for availability
* block size is validated against the requested bin

If a suitable block is found:

* its payload pointer is returned

If no block is found:

* the allocator returns the final pointer in the scanned list
* this pointer is later used to link newly created blocks into the list

---

# Extending the Heap

If `scan_memory()` does not find a reusable block, the allocator extends heap memory.

The allocator computes:

* requested allocation size
* header size
* new program break address

It then performs a `brk` syscall requesting the new break position.

If successful:

* `current_break` is updated
* a new block is initialized in the newly acquired memory region

---

# Initializing a New Block

When heap extension occurs, the allocator initializes a new block header.

The allocator uses the pointer returned by `scan_memory()` to determine the previous block in the linked list.

The new block header is populated with:

* allocation state
* block size
* previous pointer
* next pointer

The previous block's `next` field is then updated to point to the newly allocated block.

Finally:

* the new block is marked as used
* the payload pointer is returned to the caller

---

# Deallocation

The `deallocate()` function performs several validation checks before marking a block as free.

Current checks include:

* null pointer validation
* double-free detection
* heap-range validation

If validation succeeds:

* the block header is marked as available
* the block becomes reusable by future allocation requests

---

# Debugging

The allocator includes a debugging utility exposed through `debug()`.

The debugger performs a linear traversal of heap memory and prints:

* heap start address
* current break address
* heap size
* block state
* block boundaries
* block sizes
* linked-list pointers

This is primarily intended for:

* allocator verification
* debugging fragmentation
* validating linked-list updates
* inspecting heap growth

---

# Current Limitations

The allocator is still experimental and currently has several limitations:

* no adjacent block coalescence
* fragmentation in large allocations
* limited allocation reuse heuristics
* no shrinking of the program break
* limited corruption detection
* minimal alignment guarantees

Large allocations may currently waste memory if a free block is significantly larger than the requested size.

---

# Design Goals

The goal of this project is not to build a production-ready allocator.

The project is intended as a low-level systems programming exercise focused on:

* x86 assembly programming
* Linux syscalls
* heap management
* linked-list data structures
* allocator internals
* debugging low-level memory systems
* manual memory management
* ELF and process memory layout understanding

The allocator is designed to remain small, readable, and easy to inspect during debugging and experimentation.

