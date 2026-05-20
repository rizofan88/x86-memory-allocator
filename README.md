# x86 32-bit memory allocator

A small memory allocator written in x86 assembly for GNU/Linux.

It focuses on:

- low-level Linux syscalls
- heap management using `brk`
- free-list management
- fixed-size allocation bins

## Features


The allocator currently includes:

- Arbitrary-sized allocation requests
- Pointer deallocation
- Fixed-size fast allocation bins
- Heap extension through Linux kernel syscalls
- Debug heap visualization

## Build

```bash
make
```

This creates the library:

```text
build/liballocator.so
```

## Usage

Run an allocation demo:

```bash
make demo
```

Run whole test suite:

```bash
make test
```

Run unit tests only:

```bash
make test-unit
```

Run integration tests only:

```bash
make test-integration
```

Direct command for demo execution:

```bash
./build/demo_exec
```

## Example

```bash
make demo
```

Expected output:

```text
------------------------------------------------------------------------------------------
heap_start: 137220096
heap_break: 137221568
heap_size : 1472
------------------------------------------------------------------------------------------
#        state       addr         end           size      gap        prev        next      
------------------------------------------------------------------------------------------
0        USED        137220096 -> 137220128     16        0          0           137221176 
------------------------------------------------------------------------------------------
1        USED        137220128 -> 137220344     200       0          0           137220392 
------------------------------------------------------------------------------------------
2        USED        137220344 -> 137220392     32        0          0           137220688 
------------------------------------------------------------------------------------------
3        USED        137220392 -> 137220608     200       0          137220128   137220960 
------------------------------------------------------------------------------------------
4        USED        137220608 -> 137220688     64        0          0           137220880 
------------------------------------------------------------------------------------------
5        USED        137220688 -> 137220736     32        0          137220344   0         
------------------------------------------------------------------------------------------
6        USED        137220736 -> 137220880     128       0          0           137221424 
------------------------------------------------------------------------------------------
7        USED        137220880 -> 137220960     64        0          137220608   0         
------------------------------------------------------------------------------------------
8        USED        137220960 -> 137221176     200       0          137220392   137221208 
------------------------------------------------------------------------------------------
9        USED        137221176 -> 137221208     16        0          137220096   0         
------------------------------------------------------------------------------------------
10       USED        137221208 -> 137221424     200       0          137220960   0         
------------------------------------------------------------------------------------------
11       USED        137221424 -> 137221568     128       0          137220736   0         
------------------------------------------------------------------------------------------
```

## Project Structure

```text
include/     share header files     
src/         source files
test/        unit and integration tests
docs/        architecture notes
build/       generated build output and final library
```

## Portability Note

This allocator targets:

- x86 32-bit GNU/Linux
- GNU assembler (`as`)
- GNU linker (`ld`)

It depends on:

- `ld-linux.so.2`
- 32-bit `libc.so.6`

This allocator is built for a GNU/Linux machine and will not work with other operating systems such as BSD or others, without modification.

Also the program expects the ld-linux.so.2 dynamic-linker and the 32bit runtime libc.so.6 to be present on the machine and will not link without it.

## Troubleshooting

### Missing 32-bit runtime or dynamic linker

If execution fails with errors similar to:

```text
cannot open shared object file
```

or:

```text
/lib/ld-linux.so.2: No such file or directory
```

install the required 32-bit runtime libraries:

```bash
sudo apt update
sudo apt install libc6-i386 libc6-dev-i386
```

### Shared library not found at runtime

If the executable cannot locate `liballocator.so`:

```text
error while loading shared libraries: liballocator.so
```

run with:

```bash
LD_LIBRARY_PATH=./build ./build/demo_exec
```

or export it globally for the current shell session:

```bash
export LD_LIBRARY_PATH=./build:$LD_LIBRARY_PATH
```

## Status

Experimental.

Current limitations include:

- no adjacent block coalescence
- fragmentation in non-fixed-size allocations
- limited reuse optimization
- minimal deallocation validation

## Future Work

- Add adjacent block coalescence
- Improve fragmentation handling
- Add pointer validation against known allocations
- Improve free-list traversal performance
- Add block splitting and merge heuristics
- Store direct references to first free blocks
- Add allocator statistics and profiling
