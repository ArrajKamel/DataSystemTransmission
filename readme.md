# Digital Packet Transmission System in VHDL

This project implements a digital data transmission system using VHDL. The system consists of a **Packet Generator** and a **Packet Detector**, communicating over a simulated transmission line. The core of the design is built on Finite State Machines (FSMs), using **Binary Coded Decimal (BCD)** encoding for packet data and incorporating **checksum validation** for error detection.

## Features

- **Packet Generator (Tx):**
  - Assembles packets using a predefined format.
  - Encodes data using BCD (Binary Coded Decimal).
  - Computes and appends a checksum.
  - Implements a Mealy FSM for sequential transmission control.

- **Packet Detector (Rx):**
  - Continuously monitors the incoming bit stream.
  - Detects start and end of packets.
  - Extracts and decodes payload and checksum.
  - Validates packet integrity using checksum comparison.
  - Implemented as a Moore FSM.

## Packet Structure

Each packet consists of the following components:

### Start Segment (7 bits)
- **Bit 0**: Start Bit (always 0)
- **Bits 1–6**: Start Code (6-bit value)

### Data Segment (16/20/24 bits)
- Contains 4, 5, or 6 BCD-encoded digits (each 4 bits)

### Checksum (4 bits)
- XOR of all data words



## FSM Design

### Transmitter (Mealy FSM)
- Responds to external `start` signal.
- Sequentially transmits packet fields.
- Asynchronous `reset` to return to idle state.

### Receiver (Moore FSM)
- Waits for a start bit ('1').
- Stores incoming bits and reconstructs fields.
- Performs checksum validation after full packet reception.

## BCD Encoding/Decoding

- Each 4-bit BCD digit represents a decimal number (0–9).
- All fields are encoded using this standard, making the packet human-readable and easier to debug.

## Simulation and Testing

Testbenches are provided to:
- Stimulate both Tx and Rx modules.
- Verify end-to-end data integrity.
- Validate FSM transitions and error handling (e.g., bad checksum).

---

