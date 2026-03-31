# Wishbone B4 Slave Memory

A simple, synthesisable **Wishbone B4** compliant 16×8-bit memory slave written in Verilog, accompanied by a clean SystemVerilog interface-based self-checking testbench.

## Features

- 16 locations × 8-bit wide memory (addresses 0 to 15)
- Fully compliant with Wishbone B4 specification
- Single-cycle read/write access (zero wait states)
- Active-low asynchronous reset
- No burst support (single transfers only)
- SystemVerilog interface with **modports** and convenient `read()` / `write()` tasks
- Self-checking testbench with assertions and pass/fail reporting

## Files

| File               | Description                                              |
|--------------------|----------------------------------------------------------|
| `wb_mem.v`         | Synthesizable Wishbone B4 memory slave (Verilog)         |
| `wishbone_if.sv`   | SystemVerilog interface with master modport and tasks    |
| `wb_mem_tb.sv`     | Self-checking testbench                                  |
|`terminal output.txt`| terminal output                                          |
|`waveform.png`       | waveform of the design                                   |
## Address Map

| Address | Description                  |
|---------|------------------------------|
| 0–15    | 8-bit General Purpose RAM    |

## Wishbone Signals Supported

- `wb_cyc`, `wb_stb`, `wb_we`
- `wb_adr[3:0]`, `wb_dat_i[7:0]`, `wb_dat_o[7:0]`
- `wb_ack`

**Note**: ACK is asserted in the same clock cycle as a valid STB (classic single-cycle response).  
SEL, ERR, and RTY signals are not implemented in this minimal version.

## Simulation

The testbench has been successfully simulated on **Cadence Xcelium** (and should work on any SystemVerilog-compatible simulator such as Questa, VCS, or Icarus Verilog + Verilator with SV support).

### Run Simulation

```bash
# Example with Xcelium
xrun -sv wb_mem_tb.sv wb_mem.v wishbone_if.sv -access +rwc
