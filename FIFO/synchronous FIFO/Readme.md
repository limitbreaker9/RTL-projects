# Synchronous FIFO (Verilog)

This project implements a **parameterized synchronous FIFO (First-In-First-Out)** memory buffer in Verilog HDL along with simulation outputs, waveform analysis, and synthesized netlist visuals.

---

##  Project Structure

```
synchronous FIFO/
│
├── FIFOsyn.v                # RTL Design of Synchronous FIFO
├── FIFOsyn_tb.v             # Testbench
├── FIFOsyn_tb.vvp           # Compiled simulation file (Icarus Verilog)
│
├── waveform of FIFO.png     # Simulation waveform screenshot
├── FIFO terminal output.txt # Console simulation output
│
├── FIFO netlist.png         # Synthesized netlist (image)
├── fifo netlist.svg         # Synthesized netlist (vector format)
└── show.dot                 # Netlist graph source file
```

##  Design Description

###  FIFO Type
- Synchronous FIFO
- Single clock domain

###  Parameters
- `DEPTH` (default: 8)
- `DATA_WIDTH` (default: 8 bits)

###  Key Features
- Write and Read pointer with wrap-around logic
- Extra MSB bit for full detection
- Full flag generation
- Empty flag generation
- Simultaneous read & write support
- Fully synthesizable RTL

---

##  How the FIFO Works

###  Write Operation
- Enabled using `w_en`
- Data written on `posedge clk`
- Write pointer increments
- Blocked when FIFO is full

###  Read Operation
- Enabled using `r_en`
- Data read on `posedge clk`
- Read pointer increments
- Blocked when FIFO is empty

###  Full Condition
FIFO is full when:
- MSB of write and read pointers differ
- Lower bits are equal

###  Empty Condition
FIFO is empty when:
- Write pointer equals read pointer

###  Simultaneous Read & Write
If both `w_en` and `r_en` are high:
- One data element is written
- One data element is read
- FIFO occupancy remains constant
- No race condition (non-blocking assignments used)

---

##  Simulation Instructions

Simulation was performed using **Icarus Verilog**.
```
1️)Compile
iverilog -g2005-sv FIFOsyn.v FIFOsyn_tb.v -o FIFOsyn_tb.vvp
2️) Run
vvp FIFOsyn_tb.vvp
3) View Waveform
gtkwave dump.vcd
 Simulation Results
✔ Terminal Output
4)Synthesis Using Yosys

The RTL was synthesized using Yosys (Open-source synthesis tool).

1) Run Yosys
yosys
2️)Inside Yosys, execute:
read_verilog FIFOsyn.v
synth -top synchronous_fifo
write_json fifo.json
write_verilog fifo_netlist.v
write_dot show.dot
Netlist Visualization

The generated show.dot file was converted to graphical format using an online Graphviz (.dot) compiler.

Steps followed:

Open any online DOT viewer (e.g., Graphviz Online Viewer)

Upload or paste show.dot

Export as:

PNG → FIFO netlist.png

SVG → fifo netlist.svg
See:

FIFO terminal output.txt
✔ Waveform

See:

waveform of FIFO.png

Waveform demonstrates:

Proper write/read operation

Correct full and empty flag behavior

Pointer wrap-around

Safe simultaneous read/write

Synthesis

The design was synthesized and netlist generated.

Files:

FIFO netlist.png

fifo netlist.svg

show.dot

These show the gate-level structure of the FIFO after synthesis.

Concepts Demonstrated

Parameterized RTL design

Pointer arithmetic using $clog2

Wrap-around detection

Non-blocking assignments

Fork-join in testbench

Basic verification methodology

Future Improvements

Add self-checking SystemVerilog testbench

Add assertions

Add randomized stress testing

Implement Asynchronous FIFO version
```
Author
Vamsi


