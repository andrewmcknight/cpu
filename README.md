# Processor
## Overview
This project is a custom 32-bit CPU core built in structural Verilog from the ground up using fundamental logic gates. Every module in this processor (from muxes to multipliers and dividers) is constructed explicitly from AND, OR, NOT, XOR gates and their derivatives. Necessary exceptions were made for clock, D flip-flops, RAM, and ROM; they use behavioral Verilog (`reg` objects and `always` blocks) for latching.

The pipeline implements Fetch, Decode, Execute, Memory, and Writeback stages with bypassing, hazard detection, and exception handling. The processor connects to instruction memory, data memory, and a register file via an external wrapper.

The processor and wrapper were uploaded to an FPGA and  

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

Arithmetic instructions have exception detection, updating `rstatus` (register 30) when needed.

## Pipeline Organization

- **Fetch:** Supplies sequential instructions or redirect targets produced by branches and jumps
- **Decode:** Decodes opcodes, reads registers, and prepares control signals for downstream stages
- **Execute:** Runs the ALU, evaluates branch conditions, and initiates multi-cycle multiply/divide operations
- **Memory:** Performs data memory reads and writes, including forwarding of store data through explicit multiplexer trees
- **Writeback:** Selects and writes to the register file when appropriate

## Hazard Management

- **Data hazards:** The Execute stage uses prioritized bypass paths built from cascaded muxes, forwarding Execute, Memory, and Writeback results (including `rstatus`) to avoid stalls
- **Load-use hazards:** A one-cycle stall is inserted when an instruction consumes a load result prematurely
- **Long-latency operations:** Multiply and divide instructions trigger a pulse generator that starts the respective unit and holds the pipeline until `data_resultRDY` asserts
- **Control hazards:** Taken branches and jumps flush Fetch/Decode through structural control paths to prevent incorrect instruction execution

## Helper Modules:
The `helper_modules/` directory contains fundamental structural components built from primitive logic gates:
- **Adders**
- **ALU**
- **Mult/Div module** 
- **Shifters**
- **Counters**
- **Multiplexers**
- **Registers/register files** 
- **Comparators**
- **Tri-state buffers**
- **Decoder/encoders**
- and more...
