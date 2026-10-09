# Multi-Master AXI4-Lite SoC Bus Interconnect Router

A high-performance 2-Master to 2-Slave AXI4-Lite Crossbar Interconnect designed in Verilog HDL for RISC-V Multi-Core SoCs.

## Key Features
- **Protocol**: Full 5-Channel AXI4-Lite Specification (Read & Write Channels).
- **Arbitration**: Round-Robin Scheme for fair bus allocation between masters.
- **Address Decoding**: Memory-mapped routing with Decode Error (`DECERR`) handling for unmapped addresses.
- **SRAM Interface**: Integrated Dual-Port AXI4-Lite SRAM Memory Slave with Byte-Level Write Strobes (`WSTRB`).
- **Buffering**: Parameterized Decoupling FIFOs for non-blocking transactions.

## Architecture