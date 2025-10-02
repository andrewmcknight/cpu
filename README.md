# Processor

## Overview
This project implements a custom 32-bit CPU with a five-stage pipeline (Fetch, Decode, Execute, Memory, Writeback). The core supports bypassing, hazard detection, and exception handling so that the pipeline delivers correct results while keeping stalls to a minimum. The processor connects to instruction memory, data memory, and a register file wrapper, matching the interface defined for the course project.

## Instruction Set Architecture
The custom ISA covers arithmetic, logic, memory access, and control flow instructions:

- `add $rd, $rs, $rt`
- `addi $rd, $rs, N`
- `sub $rd, $rs, $rt`
- `and $rd, $rs, $rt`
- `or $rd, $rs, $rt`
- `sll $rd, $rs, shamt`
- `sra $rd, $rs, shamt`
- `mul $rd, $rs, $rt`
- `div $rd, $rs, $rt`
- `sw $rd, N($rs)`
- `lw $rd, N($rs)`
- `j T`
- `bne $rd, $rs, N`
- `jal T`
- `jr $rd`
- `blt $rd, $rs, N`
- `bex T`
- `setx T`

Arithmetic instructions include overflow detection that updates `rstatus` (register 30) when needed. The `setx` and `bex` instructions provide lightweight exception and system call semantics.

## Pipeline Organization
- **Fetch:** Supplies sequential instruction words or redirect targets produced by branches and jumps.
- **Decode:** Decodes opcodes, issues register reads, and prepares control signals for downstream stages.
- **Execute:** Runs the ALU, evaluates branch conditions, and launches multi-cycle multiply/divide operations.
- **Memory:** Performs data memory reads and writes, including forwarding of store data.
- **Writeback:** Selects the final register destination data, honoring special cases for `setx` and exception codes.

## Hazard Management
- **Data hazards:** The Execute stage uses prioritized bypass paths from Execute, Memory, and Writeback results (including `rstatus`) so dependent instructions rarely stall.
- **Load-use hazards:** A one-cycle stall is inserted when an instruction consumes the result of a preceding load before it reaches Writeback.
- **Long-latency ops:** Multiply and divide instructions trigger a pulse generator that starts the respective unit and hold the pipeline until `data_resultRDY` asserts.
- **Control hazards:** Taken branches and jumps flush Fetch/Decode to prevent incorrect instruction retirement.

## Helper Modules
Reusable datapath elements—ALU slices, shifters, multiplexers, registers, comparators, and tri-state buffers—live in `helper_modules/`. Each file now includes a short comment describing its role and I/O for quick reference while navigating the design.

## Known Issues
The current build passes the provided regression suite except for a remaining issue in the sort test, which appears to be branch-related.
