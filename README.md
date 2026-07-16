
# UART Communication Module (VHDL)

This project implements a complete Universal Asynchronous Receiver-Transmitter (UART) module in VHDL, designed for FPGA implementation. The design includes both transmitter (`uart_tx`) and receiver (`uart_rx`) modules, integrated via a top-level wrapper (`uart_top`).

## Project Overview

The architecture is designed with modularity in mind, allowing for configurable clock frequencies and baud rates via generics[cite: 1, 2, 3].

*   **`uart_tx`**: Handles serial data transmission, including start bit, 8 data bits, and stop bit generation[cite: 3].
*   **`uart_rx`**: Implements robust serial data reception, featuring input synchronization to handle metastability and a state machine to ensure accurate data sampling at the center of the bit period[cite: 1].
*   **`uart_top`**: Integrates both modules to simplify instantiation in larger projects[cite: 2].
*   **`tb_uart`**: A self-checking testbench that performs a loopback test, connecting the TX output directly to the RX input to verify end-to-end data integrity[cite: 4].

## Simulation Result

The following waveform demonstrates a successful transmission and reception of data (0x55) in a loopback configuration.

![UART Simulation Waveform](uart_output.png)

## Getting Started

### Prerequisites
*   A VHDL-compatible simulator (e.g., Vivado XSim, ModelSim, or GHDL).

### How to Run
1.  Add all `.vhd` files to your simulation project.
2.  Set `tb_uart` as the top-level testbench.
3.  Run the simulation. The testbench will automatically report a note if the loopback test passes successfully[cite: 4].
