# Processor
## Andrew McKnight (afm45)

## Description of Design

This processor is a five-stage pipelined implementation of a custom instruction set architecture (ISA). The five stages are Fetch, Decode, Execute, Memory, and Writeback. Each stage has its own set of latches to pass values to the next stage. The design supports arithmetic, logic, memory, and control-flow instructions as defined in the ISA specification.

The processor supports R-type, I-type, and J-type instructions. All control logic for branching, jumping, exception detection, and writing to special registers like `rstatus` is fully implemented. It interfaces externally with instruction memory, data memory, and the register file through the wrapper module, as required by the project specification.

The design includes full support for exception detection (overflow, divide-by-zero) and routes the corresponding codes to `rstatus` (register 30). The `setx` instruction also writes to `rstatus`. All writes to `rstatus` are prioritized and bypassed when needed.

## Bypassing

The processor uses a bypassing scheme to handle data hazards without unnecessary stalling. It checks dependencies between destination and source registers across pipeline stages and forwards results from later stages (execute, memory, or writeback) to the ALU inputs in the Execute stage.

Bypassing is implemented for both operands of the ALU. It accounts for special cases, such as dependencies involving `rstatus` (register 30), and handles scenarios where instructions like `setx` or exceptions produce data that must be used immediately in following instructions. Data written to memory in `sw` also uses bypassing when necessary.

## Stalling

Stalling is used in two primary cases: load-use hazards and mult/div latency.

For load-use hazards, if an instruction in the Execute stage is a `lw` and the next instruction tries to use its result, the processor stalls the Fetch and Decode stages for one cycle.

For multiply and divide operations, the processor stalls all pipeline stages until the result is ready. These operations are triggered by a single-cycle pulse and are handled by a mult/div unit with `busy` and `ready` signals. The pipeline only resumes execution when the result is available and the operation completes.

Control hazards caused by taken branches or jumps result in flushing the Fetch and Decode stages by injecting no-ops.

## Optimizations

The design includes several optimizations to improve pipeline efficiency:

- A pulse generator is used to trigger mult and div instructions without repeating or reissuing the operation.  
- Exception logic uses a tri-state buffer approach to ensure that only one exception is set at a time, depending on which condition is active.  
- Writeback logic prioritizes `setx` and exception-related writes to `rstatus`, simplifying control logic for register selection.  
- All bypass conditions are evaluated using priority-based assignments, reducing redundant checks and ensuring correctness across complex instruction mixes.  
- The ALU opcode logic is simplified using grouped conditions for I-type and branch instructions.

## Bugs

There is one unresolved bug in the sort test case. It appears to be related to branching, but the root cause has not yet been identified. All other test cases pass as expected.