# AXI4-Compliant Memory-Mapped Slave — SystemVerilog Verification

A simplified AXI4-based system consisting of an AXI4 slave interface and a synchronous internal memory, verified with a class-based, coverage-driven SystemVerilog testbench.

## Overview

This project implements and verifies an **AMBA AXI4-compliant memory-mapped slave**. The design receives burst read/write transactions from an AXI4 master (the testbench) and services them against an internal 4 KB synchronous memory, enforcing AXI4 protocol rules such as burst handling, write-response generation, and 4 KB boundary compliance.

The verification environment applies **Coverage-Driven Verification (CDV)** principles: SystemVerilog classes, constrained-random stimulus, functional coverage, and concurrent assertions (SVA).

## Architecture

```
        AWADDR/AWLEN/AWSIZE/AWVALID/AWREADY
   ┌───────────────►────────────────────┐
   │        WDATA/WLAST/WVALID/WREADY   │
   │   ┌───────────►───────────────┐    │
Master │        BRESP/BVALID/BREADY│    ▼
(TB)   │◄───────────◄──────────────┘  AXI4 Slave ──► Memory
   │        ARADDR/ARLEN/ARSIZE/ARVALID/ARREADY      (4 KB,
   │───────────►────────────────────────┘             1024 x 32-bit)
   │        RDATA/RRESP/RLAST/RVALID/RREADY
   │◄───────────◄──────────────────────┘
```

- **`axi4_slave`** — Interprets AXI4 write/read transactions, manages burst FSMs for both channels, enforces 4 KB boundary checks, and generates write responses (`OKAY` / `SLVERR`).
- **`axi4_memory`** — Synchronous single-port RAM, word-addressable, 1024 x 32-bit (4 KB total).

## Repository Structure

```
├── rtl/                    # Design under test
│   ├── axi4_memory.sv
│   └── axi4_slave.sv
├── tb/
│   ├── interface/          # AXI4 interface + modports
│   ├── classes/            # axi4_packet, driver, monitor, scoreboard, coverage, env
│   ├── assertions/         # SVA protocol/handshake checks
│   └── top/                # Package + testbench top
├── sim/
│   ├── filelist.f
│   ├── run.do
│   └── wave.do
├── reports/                # Coverage, logs, waveform screenshots
└── docs/                   # Project spec + final report PDF
```

## Features Verified

- Burst read/write transactions (`AWLEN`/`ARLEN`, `AWSIZE`/`ARSIZE`)
- Write response generation (`BRESP`: `OKAY` / `SLVERR`)
- Read response generation (`RRESP`: `OKAY` / `SLVERR`)
- VALID/READY handshake compliance on all five channels
- 4 KB address boundary enforcement
- Memory range checks (word-aligned addressing)

## Testbench Environment

Built entirely in SystemVerilog (no UVM), the environment includes:

- **`axi4_packet`** — transaction class encapsulating AXI4 write/read fields with constrained-random generation
- **Generator / Driver / Monitor / Scoreboard** — classes driving stimulus into the DUT via a virtual interface, sampling responses, and checking against a reference model
- **Interface + modports** — clean signal-direction separation between driver, monitor, and DUT
- **Covergroups/coverpoints** — burst length, burst size, address regions, write vs. read behavior, response types
- **Concurrent SVA assertions** — handshake stability (VALID held until READY), burst length correctness, `LAST` beat timing, boundary-check violations

## How to Run

```bash
cd sim
vsim -do run.do
```

`run.do` compiles all RTL/TB sources from `filelist.f`, elaborates the top module, runs the simulation, and generates functional/code/assertion coverage reports.

## Coverage Results

| Coverage Type       | Result |
|----------------------|--------|
| Functional Coverage  | TBD    |
| Code Coverage        | TBD    |
| Assertion Coverage   | TBD    |

See [`reports/`](./reports) for full coverage breakdowns. Any uncovered bins are documented with justification in the final project report ([`docs/`](./docs)).

## Tools

- Simulator: ModelSim / QuestaSim
- Language: SystemVerilog (IEEE 1800)

## Author

**Zyad Ahmer**
**Ramy Mohamed**
## License

This project is licensed under the MIT License — see [LICENSE](./LICENSE) for details.
