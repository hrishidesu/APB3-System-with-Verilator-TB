# APB3 SystemVerilog Design & Verification

A complete implementation of the **AMBA 3 APB (Advanced Peripheral Bus)** protocol in SystemVerilog, verified using open-source tools on Linux.

## 🚀 Project Overview
This project consists of a synthesizable APB Master and a Memory Slave, verified with a self-checking testbench.

* **RTL Language:** SystemVerilog
* **Simulator:** Verilator (v5.0+)
* **Waveforms:** GTKWave

## 🛠 Features
* **APB Master:** Robust FSM-based design (IDLE -> SETUP -> ACCESS).
* **APB Slave (RAM):** 64-word memory with **Random Wait State Injection** (pulls `PREADY` low for 0-3 cycles) to stress-test the Master's handshake logic.
* **Testbench:**
    * Directed Write & Read scenarios.
    * Automatic data integrity checks (`[PASS]` / `[FAIL]` reporting).
    * Race-condition handling using explicit protocol checks.

## 📊 Status
**✅ VERIFIED / PASSING**
* Basic Read/Write transactions confirmed.
* Stress testing with random wait states passed.
* Waveforms validated for correct Setup/Access phase timing.

## 💻 How to Run (Linux/Verilator)

1. **Install Dependencies (Arch Linux):**
   ```bash
   sudo pacman -S verilator gtkwave
   ```
2. **Run Simulation:**
   ```bash
   # Compile and Build
   verilator --binary --build -j 0 -Wall --trace -Wno-INITIALDLY -Wno-UNUSEDSIGNAL --top tb_apb_top -Irtl tb/tb_apb_top.sv rtl/apb_master.sv rtl/apb_ram_slave.sv

   # Execute
   ./obj_dir/Vtb_apb_top
   ```
3. **View Waveforms:**
    ```bash
    gtkwave logs/vlt_dump.vcd
    ```
4. **📂 Directory Structure**
   ```plaintext
   ├── rtl/               # Design Sources
   │   ├── apb_master.sv
   │   └── apb_ram_slave.sv
   ├── tb/                # Verification
   │   └── tb_apb_top.sv
   ├── logs/              # Simulation outputs (waves)
   └── obj_dir/           # Verilator compiled binaries
   ```
