# Traffic Light FSM — v3: Wishbone SystemVerilog Interface

## Folder Name
`v3-wishbone-sv-interface`

## Overview
This is the third evolution of the traffic light FSM project.  
It upgrades the Wishbone integration from raw Verilog flat ports (v2) to a  
proper **SystemVerilog interface** (`wishbone_if`) with modports and built-in  
`read` / `write` tasks. The design is fully simulated and verified on  
**Cadence Xcelium 25.03** via EDA Playground.

---

## Project Evolution

| Version | Folder | Description |
|---------|--------|-------------|
| v1 | `v1-basic-fsm` | Basic Moore FSM — hardcoded green/yellow timings |
| v2 | `v2-wishbone-registers` | Wishbone B3 slave — runtime configurable timings via flat Verilog ports |
| **v3** | **`v3-wishbone-sv-interface`** | **SystemVerilog `wishbone_if` interface with modports and tasks** |
| v4 *(planned)* | `v4-riscv-cpu` | Sakthi RISC-V CPU core as Wishbone master |

---

## Architecture

```
                    ┌──────────────────────────────────────┐
                    │          top_traffic_fsm              │
                    │                                      │
  wishbone_if ───►  │  wb_reg_wrapper ──► reg_block        │
  (SV interface)    │       │                              │
                    │    timer ──► fsm ──► output_module   │
                    │                          │           │
                    └──────────────────────────┼───────────┘
                                               ▼
                                         NS[2:0]  EW[2:0]
```

---

## Register Map

| Address | Register | Description |
|---------|----------|-------------|
| 0x0 | CONTROL | Bit[0] = FSM enable/disable |
| 0x1 | GREEN_TIME | Green phase duration (shadow register) |
| 0x2 | YELLOW_TIME | Yellow phase duration (shadow register) |
| 0x3 | STATUS | `{update_pending, state[1:0]}` |

> **Shadow register behaviour:** Writes to GREEN_TIME and YELLOW_TIME go into  
> shadow registers first. They take effect only after the current full FSM  
> cycle completes (state `11 → 00` transition), ensuring glitch-free updates.

---

## FSM States

| State | NS | EW |
|-------|----|----|
| `00` | Green | Red |
| `01` | Yellow | Red |
| `10` | Red | Green |
| `11` | Red | Yellow |

---

## Files

| File | Type | Description |
|------|------|-------------|
| `wishbone_if.sv` | SystemVerilog | Wishbone interface with modports and read/write tasks |
| `top_module.v` | Verilog | Top-level integration of all submodules |
| `fsm_module.v` | Verilog | Next-state combinational logic |
| `timer_module.v` | Verilog | Configurable count-down timer |
| `output_module.v` | Verilog | Moore output decoder (NS, EW) |
| `register_write_interface.v` | Verilog | Register block with shadow registers |
| `wishbone_wrapper.v` | Verilog | Wishbone B3 slave wrapper |
| `traffic_light_fsm_tb.sv` | SystemVerilog | Testbench using wishbone_if tasks |

---

## SystemVerilog Interface — `wishbone_if`

```systemverilog
interface wishbone_if(input logic clk, input logic rst_n);
    logic        cyc, stb, we;
    logic [3:0]  adr;
    logic [31:0] dat_i;   // master → slave
    logic [31:0] dat_o;   // slave  → master
    logic        ack;

    modport master(input dat_o, ack,
                   output cyc, stb, we, adr, dat_i,
                   import read, write);

    modport slave(input cyc, stb, we, adr, dat_i,
                  output dat_o, ack);

    task automatic read(...);   // built-in read transaction
    task automatic write(...);  // built-in write transaction
endinterface
```

### Using the tasks in testbench

```systemverilog
wishbone_if i(.clk(clk), .rst_n(rst_n));

i.write(4'd1, 32'd15);   // set green_time = 15
i.write(4'd2, 32'd5);    // set yellow_time = 5
i.read (4'd1, data);     // read back green_time
```

---

## Simulation

**Tool:** Cadence Xcelium 25.03 on EDA Playground

```
xrun -timescale 1ns/1ns -sysv -access +rw design.sv testbench.sv
```

**Files for EDA Playground:**
- `design.sv` — all Verilog modules combined
- `testbench.sv` — `traffic_light_fsm_tb` + `wishbone_if`

---

## Verified Behaviour

| Test | Expected | Result |
|------|----------|--------|
| Reset defaults | green=10, yellow=3, enable=1 | ✅ Pass |
| Write green_time=15 | shadow updated, pending=1 | ✅ Pass |
| Write yellow_time=5 | shadow updated, pending=1 | ✅ Pass |
| Read back green_time | returns 15 | ✅ Pass |
| Shadow→main update | takes effect after full FSM cycle | ✅ Pass |
| FSM cycling | 00→01→10→11→00 | ✅ Pass |
| NS/EW outputs | correct for each state | ✅ Pass |
| green phase count | exactly 15 clocks | ✅ Pass |
| yellow phase count | exactly 5 clocks | ✅ Pass |

---

## Known Design Notes

- `dat_o` is held after read (no clear on de-assert) — required for correct  
  read task capture timing.
- ACK deasserts one clock after CYC/STB goes low (registered ACK). This is  
  compliant with Wishbone B3 registered feedback cycle.
- One idle clock between consecutive bus transactions is required.

---

## Next: v4 — Sakthi RISC-V CPU Integration

The `wishbone_if.master` modport will be connected to the **Sakthi RISC-V  
CPU core**, replacing the testbench stimulus. The CPU will memory-map the  
traffic light registers and control timing via software load/store  
instructions.

```
Sakthi RISC-V  ──[wishbone_if.master]──►  top_traffic_fsm  ──►  NS / EW
```

---

## License
MIT
