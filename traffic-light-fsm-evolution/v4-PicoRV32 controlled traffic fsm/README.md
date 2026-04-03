# Traffic Light FSM — Version 4 (CPU-Controlled SoC)

> **Evolution:** This is v4 of the traffic light FSM project — the most advanced iteration, where the FSM is no longer hardcoded but is fully controlled by a **PicoRV32 soft-core CPU** over a **Wishbone bus**. The CPU writes green/yellow timing values and enables the FSM at runtime via memory-mapped registers.

---

## Table of Contents

- [Overview](#overview)
- [What's New in v4](#whats-new-in-v4)
- [Architecture](#architecture)
- [File Structure](#file-structure)
- [Memory Map](#memory-map)
- [Register Description](#register-description)
- [FSM State Encoding](#fsm-state-encoding)
- [Firmware](#firmware)
  - [Compilation Commands](#compilation-commands)
- [Simulation](#simulation)
  - [Compile & Run](#compile--run)
  - [Waveform (waveform.png)](#waveform-wavefrom)
- [Simulation Results](#simulation-results)
- [Known Warnings](#known-warnings)
- [How to View the Waveform](#how-to-view-the-waveform)

---

## Overview

This project implements a **two-direction traffic light controller** (North-South and East-West) using a synthesizable Verilog RTL design integrated with a PicoRV32 RISC-V CPU. The CPU configures the FSM at boot time by writing to memory-mapped peripheral registers over a Wishbone interconnect.

The 3-bit output encoding for each direction is:
| Signal | Meaning |
|--------|---------|
| `001`  | Green   |
| `010`  | Yellow  |
| `100`  | Red     |

---

## What's New in v4

| Feature | v1–v3 | v4 |
|---------|-------|----|
| Green/Yellow timing | Hardcoded | CPU-programmable at runtime |
| Control | Pure RTL FSM | PicoRV32 CPU + Wishbone bus |
| Register interface | None | Memory-mapped register block |
| Firmware | None | C firmware compiled for RISC-V |
| Safe update | No | Shadow registers — timing updates apply only after a full FSM cycle completes |
| Status register | No | `update_pending` bit + current state readable |

---

## Architecture

```
+----------------------------------------------------------+
|                      top_soc_v4                          |
|                                                          |
|   +----------------+      Wishbone Bus                  |
|   | PicoRV32 CPU   |<--------------------------------+  |
|   | (picorv32_wb)  |                                 |  |
|   +----------------+                                 |  |
|         |                                            |  |
|         | Address Decode                             |  |
|         |  0x0xxxxxxx → RAM                         |  |
|         |  0x1xxxxxxx → Peripheral (FSM)             |  |
|         |                                            |  |
|   +-----+-------+        +------------------------+ |  |
|   |   wb_ram    |        |   top_traffic_fsm      | |  |
|   | (1KB SRAM)  |        | +--------------------+ | |  |
|   | firmware.hex|        | | wb_reg_wrapper     | | |  |
|   +-------------+        | |  (Wishbone slave)  | | |  |
|                           | +--------------------+ | |  |
|                           | | reg_block          | | |  |
|                           | |  CONTROL, GREEN,   | | |  |
|                           | |  YELLOW, STATUS    | | |  |
|                           | +--------------------+ | |  |
|                           | | fsm_module         | | |  |
|                           | | timer_module       | | |  |
|                           | | output_module      | | |  |
|                           +------------------------+ |  |
+----------------------------------------------------------+
                                    |
                            NS[2:0], EW[2:0]  (traffic outputs)
```

### Sub-modules

| Module | File | Description |
|--------|------|-------------|
| `top_soc_v4` | `top_soc_v4.v` | Top-level SoC integrating CPU, RAM, and FSM peripheral |
| `picorv32_wb` | `picorv32.v` | PicoRV32 RISC-V CPU with Wishbone master interface |
| `wb_ram` | `wb_ram.v` | 1 KB Wishbone-attached SRAM; loads `firmware.hex` at reset |
| `top_traffic_fsm` | `top_module.v` | Traffic FSM peripheral top; connects all sub-blocks |
| `wb_reg_wrapper` | `wishbone_wrapper.v` | Wishbone slave — decodes bus transactions, drives `reg_block` |
| `reg_block` | `register_write_interface.v` | Memory-mapped registers with shadow + safe-update logic |
| `fsm` | `fsm_module.v` | Pure combinational next-state logic |
| `timer` | `timer_module.v` | Counts clock cycles per state; resets on state change |
| `output_module` | `output_module.v` | Decodes 2-bit FSM state → 3-bit NS/EW light outputs |

---

## File Structure

```
traffic-light-fsm-v4/
├── top_soc_v4.v               # SoC top-level
├── picorv32.v                 # PicoRV32 CPU (Wishbone variant)
├── wb_ram.v                   # 1KB Wishbone SRAM
├── top_module.v               # Traffic FSM peripheral top
├── wishbone_wrapper.v         # Wishbone slave interface
├── register_write_interface.v # Register block (CONTROL, GREEN, YELLOW, STATUS)
├── fsm_module.v               # FSM next-state logic
├── timer_module.v             # Per-state cycle counter
├── output_module.v            # State → light output decoder
├── tb_top_soc_v4.sv           # SystemVerilog testbench
├── firmware.c                 # C firmware source
├── firmware.hex               # Compiled firmware (loaded into wb_ram via $readmemh)
├── .gitignore                 # Excludes build artifacts (*.elf, *.bin, *.out)
├── waveform.png               # GTKWave screenshot of simulation
└── README.md                  # This file
```

---

## Memory Map

| Address Range | Size | Mapped To |
|---------------|------|-----------|
| `0x00000000 – 0x0FFFFFFF` | — | Instruction + Data RAM (1 KB) |
| `0x10000000 – 0x1FFFFFFF` | — | Traffic FSM Peripheral Registers |

The CPU stack is initialized at `0x000003FC` (top of 1 KB RAM). The program counter starts at `0x00000000`.

---

## Register Description

Base address of peripheral: `0x10000000`

| Offset | Name | Access | Description |
|--------|------|--------|-------------|
| `+0x00` (`0x10000000`) | `CONTROL_REG` | R/W | Bit[0] = `enable`. Write `1` to start FSM, `0` to halt it. |
| `+0x04` (`0x10000004`) | `GREEN_TIME_REG` | R/W | Bits[3:0] = green phase duration in clock cycles. Written to shadow register immediately. |
| `+0x08` (`0x10000008`) | `YELLOW_TIME_REG` | R/W | Bits[3:0] = yellow phase duration in clock cycles. Written to shadow register immediately. |
| `+0x0C` (`0x1000000C`) | `STATUS_REG` | R | Bits[1:0] = current FSM state; Bit[2] = `update_pending` flag |

> **Safe Update Mechanism:** Writing `GREEN_TIME_REG` or `YELLOW_TIME_REG` does **not** immediately change the live timing. Values are stored in shadow registers, and only transferred to the active registers when the FSM completes a full cycle (transition from state `11` → `00`). This prevents glitches mid-cycle.

---

## FSM State Encoding

| State (`present[1:0]`) | NS Signal | EW Signal | Phase |
|------------------------|-----------|-----------|-------|
| `2'b00` | Green (`001`) | Red (`100`) | NS green |
| `2'b01` | Yellow (`010`) | Red (`100`) | NS yellow |
| `2'b10` | Red (`100`) | Green (`001`) | EW green |
| `2'b11` | Red (`100`) | Yellow (`010`) | EW yellow |

State transitions are governed by the timer reaching the configured `green_time` or `yellow_time` values.

---

## Firmware

**Source file:** `firmware.c`

```c
#define CONTROL_REG      (*((volatile int*) 0x10000000))
#define GREEN_TIME_REG   (*((volatile int*) 0x10000004))
#define YELLOW_TIME_REG  (*((volatile int*) 0x10000008))

void _start() {
    GREEN_TIME_REG  = 15;   // Set green phase = 15 clock cycles
    YELLOW_TIME_REG = 5;    // Set yellow phase = 5 clock cycles
    CONTROL_REG     = 1;    // Enable FSM (start running)
    while(1);               // Halt CPU (spin forever)
}
```

The firmware writes green time = **15**, yellow time = **5**, then enables the FSM, and loops forever (since there is no OS to return to).

### Compilation Commands

The firmware is compiled using the **RISC-V 64-bit non-ELF (bare-metal) GCC toolchain** (`riscv64-unknown-elf-gcc`). The key requirement is that `$readmemh` in Verilog needs the firmware in **Intel HEX format**, which is produced via `objcopy`.

> **What to commit vs ignore:**
> - `firmware.c` ✅ — source, always commit
> - `firmware.hex` ✅ — required by `$readmemh` in `wb_ram.v` at simulation time, commit this
> - `firmware.elf` ❌ — build artifact, add to `.gitignore`
> - `firmware.bin` ❌ — build artifact, add to `.gitignore`
>
> Recommended `.gitignore` for this folder:
> ```
> *.elf
> *.bin
> *.o
> *.out
> sim.out
> ```

**Step 1 — Compile C to ELF:**
```bash
riscv64-unknown-elf-gcc \
  -march=rv32i \
  -mabi=ilp32 \
  -nostdlib \
  -nostartfiles \
  -Ttext=0x00000000 \
  -o firmware.elf \
  firmware.c
```

**Step 2 — Convert ELF to raw binary:**
```bash
riscv64-unknown-elf-objcopy \
  -O binary \
  firmware.elf \
  firmware.bin
```

**Step 3 — Convert binary to Intel HEX (for `$readmemh`):**
```bash
riscv64-unknown-elf-objcopy \
  -O ihex \
  firmware.elf \
  firmware.hex
```

> **Why these flags?**
> - `-march=rv32i` — target the 32-bit base integer RISC-V ISA (PicoRV32 is RV32I).
> - `-mabi=ilp32` — use the 32-bit integer ABI.
> - `-nostdlib -nostartfiles` — no C standard library or startup files; `_start` is our own entry point.
> - `-Ttext=0x00000000` — link code starting at address `0x0`, which is where `wb_ram` is mapped and where `PROGADDR_RESET` is set in the CPU instantiation.
> - The `riscv64-unknown-elf-gcc` toolchain (64-bit non-ELF variant) is used because it is the standard cross-compiler for bare-metal RISC-V targets and supports `-march=rv32i` to produce 32-bit code.

> **Note on `$readmemh` warning:** During simulation you will see:
> `WARNING: wb_ram.v:18: $readmemh(firmware.hex): Not enough words in the file for the requested range [0:255].`
> This is expected — `firmware.hex` only contains the small firmware binary (a few instructions), which does not fill the entire 1 KB RAM. The remaining locations are initialized to `x` (don't care) by the simulator, which is fine since the CPU never accesses them.

---

## Simulation

### Compile & Run

Simulation uses **Icarus Verilog (iverilog)** with a SystemVerilog testbench.

**Step 1 — Compile:**
```bash
iverilog -g2012 \
  -o sim.out \
  tb_top_soc_v4.sv \
  top_soc_v4.v \
  picorv32.v \
  wb_ram.v \
  top_module.v \
  wishbone_wrapper.v \
  register_write_interface.v \
  fsm_module.v \
  timer_module.v \
  output_module.v
```

**Step 2 — Run simulation:**
```bash
vvp sim.out
```

This produces `traffic.vcd` (waveform dump) and prints signal trace to stdout.

**Step 3 — View waveform:**
```bash
gtkwave traffic.vcd
```

### Testbench Behaviour (`tb_top_soc_v4.sv`)

- Clock period: **10 ns** (toggled every 5 ns).
- Reset (`rst_n`) held low for **40 ns**, then de-asserted.
- At `T = 2000 ns`, the testbench checks:
  - `green_time_shadow == 15` ✅
  - `yellow_time_shadow == 5` ✅
  - `enable == 1` ✅
- FSM state transitions are logged whenever the state changes.
- Simulation ends at `T = 20,000 ns` (`#20000 $finish`).
- A `$dumpvars` call records all signals to `traffic.vcd`.

---

## Waveform (`waveform.png`)

The screenshot (`waveform.png`) shows the GTKWave view of `traffic.vcd` around the **6100–6200 ns** time window. The following signals are visible:

| Signal | Observed Behaviour |
|--------|--------------------|
| `EW[2:0]` | Transitions: `001` (Green) → `010` (Yellow) → `100` (Red) |
| `NS[2:0]` | Transitions: `100` (Red) → `001` (Green) |
| `clk` | 10 ns period clock running correctly |
| `cpu_trap` | Stays low — CPU is executing correctly, no illegal instruction |
| `prev_state[1:0]` | Shows FSM state history: `10` → `11` → `00` |
| `rst_n` | Remains high (de-asserted) — system out of reset |

The waveform confirms the FSM cycling through all four states with the CPU-programmed timing values (green = 15 cycles, yellow = 5 cycles) applied correctly after the first full FSM cycle completes.

---

## Simulation Results

From `output.txt` (simulation console log):

```
CHECK at T=2000ns
PASS: green_time_shadow = 15
PASS: yellow_time_shadow = 5
PASS: enable = 1
```

All three self-checks pass. The simulation also shows the FSM cycling cleanly through all four states at the end of the run (near T=80 µs), running on the CPU-programmed timing of green=15, yellow=5:

```
FSM T=79915000: state 00 to 01 | NS=010 EW=100 | green=15 yellow=5
FSM T=79965000: state 01 to 10 | NS=100 EW=001 | green=15 yellow=5
```

This confirms the safe shadow-register update mechanism worked correctly — the new timing values (written by CPU at ~T=355 ns) propagated to the live registers only after a full FSM cycle, and the FSM then runs at green=15 / yellow=5 as intended.

---

## Known Warnings

| Warning | Cause | Action |
|---------|-------|--------|
| `$readmemh: Not enough words in the file for the requested range [0:255]` | `firmware.hex` is smaller than the 256-word (1 KB) RAM | Safe to ignore — unused RAM locations are don't-care |

---

## How to View the Waveform

1. Install GTKWave: `sudo apt install gtkwave`
2. Run: `gtkwave traffic.vcd`
3. In the SST panel, expand `tb_top_soc_v4` and drag signals into the wave window.
4. Suggested signals to add: `clk`, `rst_n`, `NS[2:0]`, `EW[2:0]`, `cpu_trap`, `prev_state[1:0]`, and internal signals like `dut.dut.present`, `dut.dut.t1.count`, `dut.dut.wb.r1.green_time`, `dut.dut.wb.r1.update_pending`.

---

## What to Name This File

Name it **`README.md`** and place it in the `v4/` subfolder of your repo:

```
RTL-projects/
└── traffic-light-fsm-evolution/
    ├── v1/
    ├── v2/
    ├── v3/
    └── v4/
        ├── README.md          ← this file
        ├── .gitignore         ← excludes *.elf, *.bin, sim.out
        ├── top_soc_v4.v
        ├── ...
        ├── firmware.c
        ├── firmware.hex       ← commit this (needed for simulation)
        └── waveform.png
```

If you want a specific naming convention consistent with your other versions, `README_v4.md` also works, but standard GitHub practice renders `README.md` automatically on the folder page.
