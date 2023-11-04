import 'package:iriscv_board/riscv/registers.dart';

import 'memory.dart';

abstract class Instruction {
  Instruction();

  void execute(Registers registers, Memory memory);

  @override
  String toString() => 'Instruction';
}

class LUIInstruction extends Instruction {
  final int rd; // Destination register
  final int imm; // Immediate value

  LUIInstruction(this.rd, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // The immediate value is logically shifted left by 12 bits and interpreted as a signed 32-bit integer
    int result = (imm << 12).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'LUI x$rd, $imm';
  }
}

class AUIPCInstruction extends Instruction {
  final int rd; // Destination register
  final int imm; // Immediate value

  AUIPCInstruction(this.rd, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int currentPC = registers.getPC();
    int shiftedImmediate = imm << 12;
    int result = (currentPC + shiftedImmediate).toSigned(32);
    registers.setGPR(rd, result);
    registers.incrementPC();
  }

  @override
  String toString() => 'AUIPC x$rd, $imm';
}

class ADDIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  ADDIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int immediateValue = (imm << 20) >> 20;
    int result = (rs1Value + immediateValue).toSigned(32);
    registers.setGPR(rd, result);
    registers.incrementPC();
  }

  @override
  String toString() => 'ADDI x$rd, x$rs1, $imm';
}

class SLTIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  SLTIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int immediateValue = (imm << 20) >> 20;
    int result = (rs1Value < immediateValue) ? 1 : 0;
    registers.setGPR(rd, result);
    registers.incrementPC();
  }

  @override
  String toString() => 'SLTI x$rd, x$rs1, $imm';
}

class SLTIUInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  SLTIUInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1) & 0xFFFFFFFF;
    int immediateValue = imm & 0xFFF;
    int result = (rs1Value < immediateValue) ? 1 : 0;
    registers.setGPR(rd, result);
    registers.incrementPC();
  }

  @override
  String toString() => 'SLTIU x$rd, x$rs1, $imm';
}

class XORIInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register
  final int imm; // Immediate value

  XORIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);

    // Sign-extend the immediate value from 12 to 32 bits correctly
    // This operation fills the top 20 bits with the 12th bit of imm
    int signExtendedImm = (imm << 20) >> 20;

    // Perform the XOR operation
    int result = (rs1Value ^ signExtendedImm).toSigned(32);

    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'XORI x$rd, x$rs1, $imm';
}

class XORInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  XORInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve values from the source registers
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);

    // Perform bitwise XOR
    int result = (rs1Value ^ rs2Value).toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'XOR x$rd, x$rs1, x$rs2';
}

class SRLInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1
  final int rs2; // Source register 2

  SRLInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    // Convert to unsigned and apply logical right shift
    int result = (rs1Value.toUnsigned(32) >> rs2).toSigned(32);
    // Store the result back as a signed integer
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'SRL x$rd, x$rs1, $rs2';
  }
}

class SBInstruction extends Instruction {
  final int rs1; // Source register 1 (base address)
  final int rs2; // Source register 2 (data to store)
  final int imm; // Immediate value (offset)

  SBInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int data = registers.getGPR(rs2);
    int address = baseAddress + imm;
    memory.storeByte(
        address, data & 0xFF); // Store only the least significant byte
  }

  @override
  String toString() {
    return 'SB x$rs2, $imm(x$rs1)';
  }
}

class SHInstruction extends Instruction {
  final int rs1; // Source register 1 (base address)
  final int rs2; // Source register 2 (data to store)
  final int imm; // Immediate value (offset)

  SHInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int data = registers.getGPR(rs2);
    int address = baseAddress + imm;
    memory.storeHalfword(
        address, data & 0xFFFF); // Store only the least significant halfword
  }

  @override
  String toString() {
    return 'SH x$rs2, $imm(x$rs1)';
  }
}

class BLTInstruction extends Instruction {
  final int rs1; // Source register 1
  final int rs2; // Source register 2
  final int imm; // Immediate value (offset for the branch)

  BLTInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);
    if (rs1Value < rs2Value) {
      // Branch taken: update the program counter by the offset
      int pc = registers.getPC();
      registers.setPC(pc + imm);
    }
  }

  @override
  String toString() {
    return 'BLT x$rs1, x$rs2, $imm';
  }
}

class SRAInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1
  final int rs2; // Source register 2

  SRAInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    // Arithmetic right shift
    int result = (rs1Value >> rs2).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'SRA x$rd, x$rs1, $rs2';
  }
}

class ORInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1
  final int rs2; // Source register 2

  ORInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);
    int result = (rs1Value | rs2Value).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'OR x$rd, x$rs1, x$rs2';
  }
}

class ANDInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1
  final int rs2; // Source register 2

  ANDInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);
    int result = (rs1Value & rs2Value).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'AND x$rd, x$rs1, x$rs2';
  }
}

class LBInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1 (base register)
  final int imm; // Immediate value (offset)

  LBInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + imm;
    // Load the byte and sign-extend it to 32 bits
    int value = memory.loadByte(address).toSigned(8);
    registers.setGPR(rd, value);
  }

  @override
  String toString() {
    return 'LB x$rd, $imm(x$rs1)';
  }
}

class LBUInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1 (base register)
  final int imm; // Immediate value (offset)

  LBUInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + imm;
    // Load the byte and zero-extend it to 32 bits
    int value = memory.loadUnsignedByte(address);
    registers.setGPR(rd, value);
  }

  @override
  String toString() {
    return 'LBU x$rd, $imm(x$rs1)';
  }
}

class LHInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1 (base register)
  final int imm; // Immediate value (offset)

  LHInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + imm;
    // Load the halfword and sign-extend it to 32 bits
    int value = memory.loadHalfword(address).toSigned(16);
    registers.setGPR(rd, value);
  }

  @override
  String toString() {
    return 'LH x$rd, $imm(x$rs1)';
  }
}

class LHUInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1 (base register)
  final int imm; // Immediate value (offset)

  LHUInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + imm;
    int value = memory.loadUnsignedHalfword(address);
    registers.setGPR(rd, value);
  }

  @override
  String toString() {
    return 'LHU x$rd, $imm(x$rs1)';
  }
}

class LWInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register (base address)
  final int imm; // Immediate value (offset)

  LWInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + imm;
    int value = memory.fetch(address);
    registers.setGPR(rd, value);
  }

  @override
  String toString() {
    return 'LW x$rd, ${imm}(x$rs1)';
  }
}

class ORIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  ORIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(rs1);

    // Sign-extend the 12-bit immediate value
    int signExtendedImmediate = (imm << 20) >> 20;

    // Perform bitwise OR operation
    int result = (rs1Value | signExtendedImmediate).toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'ORI x$rd, x$rs1, $imm';
}

class ANDIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  ANDIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int signExtendedImmediate = (imm << 20) >> 20;
    int result = (rs1Value & signExtendedImmediate).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'ANDI x$rd, x$rs1, $imm';
}

class SLLIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  SLLIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(rs1);

    // Perform logical left shift operation
    int result = (rs1Value << imm).toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SLLI x$rd, x$rs1, $imm';
}

class SRLIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  SRLIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(rs1);

    // Perform logical right shift operation
    int result = (rs1Value >> imm).toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SRLI x$rd, x$rs1, $imm';
}

class SRAIInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int imm;

  SRAIInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(rs1);

    // Perform arithmetic right shift operation
    int result = rs1Value >> imm;
    if (rs1Value & (1 << 31) != 0) {
      // If the most significant bit is set
      result |= (~0 << (32 - imm)); // Set the upper bits
    }
    result = result.toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SRAI x$rd, x$rs1, $imm';
}

class ADDInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  ADDInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int result = (registers.getGPR(rs1) + registers.getGPR(rs2)).toSigned(32);
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'ADD x$rd, x$rs1, x$rs2';
}

class SUBInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  SUBInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int result = (registers.getGPR(rs1) - registers.getGPR(rs2)).toSigned(32);
    ;
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SUB x$rd, x$rs1, x$rs2';
}

class SLLInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  SLLInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register rs1
    int rs1Value = registers.getGPR(rs1);

    // Get the shift amount from the source register rs2 (only lower 5 bits are used)
    int shiftAmount = registers.getGPR(rs2) & 0x1F;

    // Perform logical left shift operation
    int result = (rs1Value << shiftAmount).toSigned(32);

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SLL x$rd, x$rs1, x$rs2';
}

class SLTInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  SLTInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);

    // Check if rs1Value is less than rs2Value
    int result = (rs1Value < rs2Value) ? 1 : 0;

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SLT x$rd, x$rs1, x$rs2';
}

class SLTUInstruction extends Instruction {
  final int rd;
  final int rs1;
  final int rs2;

  SLTUInstruction(this.rd, this.rs1, this.rs2) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Treat the register values as unsigned by using a mask
    int rs1Value = registers.getGPR(rs1) & 0xFFFFFFFF;
    int rs2Value = registers.getGPR(rs2) & 0xFFFFFFFF;

    // Check if rs1Value is less than rs2Value in unsigned comparison
    int result = (rs1Value < rs2Value) ? 1 : 0;

    // Store the result in the destination register
    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'SLTU x$rd, x$rs1, x$rs2';
}

class BEQInstruction extends Instruction {
  final int rs1;
  final int rs2;
  final int imm; // This is the immediate value shifted and sign-extended

  BEQInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);

    if (rs1Value == rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + imm);
    }
  }

  @override
  String toString() => 'BEQ x$rs1, x$rs2, $imm';
}

class BGEInstruction extends Instruction {
  final int rs1;
  final int rs2;
  final int imm; // This is the immediate value shifted and sign-extended

  BGEInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);

    if (rs1Value >= rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + imm);
    }
  }

  @override
  String toString() => 'BGE x$rs1, x$rs2, $imm';
}

class BNEInstruction extends Instruction {
  final int rs1;
  final int rs2;
  final int imm; // This is the immediate value shifted and sign-extended

  BNEInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);

    if (rs1Value != rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + imm);
    }
  }

  @override
  String toString() => 'BNE x$rs1, x$rs1, $imm';
}

class BLTUInstruction extends Instruction {
  final int rs1;
  final int rs2;
  final int imm;

  BLTUInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {}

  @override
  String toString() => 'BLTU x$rs1, x$rs1, $imm';
}

class BGEUInstruction extends Instruction {
  final int rs1;
  final int rs2;
  final int imm;

  BGEUInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {}

  @override
  String toString() => 'BGEU x$rs1, x$rs1, $imm';
}

class ECALLInstruction extends Instruction {
  ECALLInstruction() : super();

  @override
  void execute(Registers registers, Memory memory) {
    // For this example, we're throwing an exception when ECALL is executed.
    throw Exception(
        'ECALL instruction executed. System call interruption generated.');
  }

  @override
  String toString() => 'ECALL';
}

class FENCEInstruction extends Instruction {
  FENCEInstruction() : super();

  @override
  void execute(Registers registers, Memory memory) {
    // For a simple emulation, the FENCE operation might not have any effect.
  }

  @override
  String toString() => 'FENCE';
}

class JALInstruction extends Instruction {
  final int rd; // Destination register to save the return address
  final int imm; // This is the immediate value shifted and sign-extended

  JALInstruction(this.rd, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int returnAddress =
        registers.getPC() + 4; // Address of the next instruction
    registers.setGPR(rd, returnAddress); // Save return address in rd

    // Jump by setting the program counter to its current value + offset
    registers.setPC(registers.getPC() + imm);
  }

  @override
  String toString() => 'JAL x$rd, $imm';
}

class SWInstruction extends Instruction {
  final int rs1; // Source register 1 (base address)
  final int rs2; // Source register 2 (data to store)
  final int imm; // 12-bit signed offset

  SWInstruction(this.rs1, this.rs2, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int address = registers.getGPR(rs1) + imm; // Calculate memory address
    int valueToStore = registers.getGPR(rs2); // Get data from rs2

    memory.store(address, valueToStore); // Store the word in memory
  }

  @override
  String toString() => 'SW x$rs2, x$rs1, $imm';
}

class CSRRSInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register (can be x0)
  final int csr; // CSR register index

  CSRRSInstruction(this.rd, this.rs1, this.csr) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int csrValue = registers.getCSR(csr); // Read CSR value
    registers.setGPR(rd, csrValue); // Write CSR value to rd

    if (rs1 != 0) {
      // If rs1 is not x0, set the CSR bits that are set in rs1
      int rs1Value = registers.getGPR(rs1);
      int newCsrValue = csrValue | rs1Value;
      registers.setCSR(csr, newCsrValue);
    }
  }

  @override
  String toString() => 'CSRRS x$rd, $csr, x$rs1';
}

class CSRRWIInstruction extends Instruction {
  final int rd; // Destination register
  final int csr; // CSR register index
  final int zimm; // Immediate value

  CSRRWIInstruction(this.rd, this.csr, this.zimm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int csrValue = registers.getCSR(csr); // Read CSR value
    registers.setGPR(rd, csrValue); // Write CSR value to rd

    registers.setCSR(csr, zimm); // Set CSR to the immediate value
  }

  @override
  String toString() => 'CSRRWI x$rd, $csr, $zimm';
}

class CSRRWInstruction extends Instruction {
  final int rd; // Destination register
  final int csr; // CSR register index
  final int rs1; // Source register

  CSRRWInstruction(this.rd, this.csr, this.rs1) : super();

  @override
  void execute(Registers registers, Memory memory) {
    int csrValue = registers.getCSR(csr); // Read CSR value
    int sourceValue = registers.getGPR(rs1); // Read source register value

    registers.setGPR(rd, csrValue); // Write CSR value to rd
    registers.setCSR(csr, sourceValue); // Set CSR to the source register value
  }

  @override
  String toString() => 'CSRRW x$rd, $csr, x$rs1';
}

class CSRRCInstruction extends Instruction {
  final int rd; // Destination register
  final int csr; // CSR register index
  final int rs1; // Source register

  CSRRCInstruction(this.rd, this.csr, this.rs1) : super();

  @override
  void execute(Registers registers, Memory memory) {}

  @override
  String toString() => 'CSRRC x$rd, $csr, x$rs1';
}

class CSRRSIInstruction extends Instruction {
  final int rd; // Destination register
  final int csr; // CSR register index
  final int zimm; // Source register

  CSRRSIInstruction(this.rd, this.csr, this.zimm) : super();

  @override
  void execute(Registers registers, Memory memory) {}

  @override
  String toString() => 'CSRRS x$rd, $csr, x$zimm';
}

class CSRRCIInstruction extends Instruction {
  final int rd; // Destination register
  final int csr; // CSR register index
  final int zimm; // Source register

  CSRRCIInstruction(this.rd, this.csr, this.zimm) : super();

  @override
  void execute(Registers registers, Memory memory) {}

  @override
  String toString() => 'CSRRC x$rd, $csr, x$zimm';
}

class JALRInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register (base register)
  final int imm; // Immediate value

  JALRInstruction(this.rd, this.rs1, this.imm) : super();

  @override
  void execute(Registers registers, Memory memory) {
    // Save the return address (next instruction) in the destination register
    int returnAddress = registers.getPC() + 4;
    registers.setGPR(rd, returnAddress);

    // Calculate the jump target address
    int targetAddress = (registers.getGPR(rs1) + imm) & ~1;
    registers.setPC(targetAddress);
  }

  @override
  String toString() {
    return 'JALR x$rd, x$rs1, $imm';
  }
}
