import 'package:iriscv_board/riscv/registers.dart';

import 'memory.dart';

abstract class Instruction {
  final List<int> operands;

  Instruction(this.operands);

  void execute(Registers registers, Memory memory);

  @override
  String toString() => 'Instruction';
}

class LUIInstruction extends Instruction {
  LUIInstruction(int rd, int immediate) : super([rd, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int immediateValue = operands[1];
    int result = immediateValue << 12;
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'LUI x${operands[0]}, ${operands[1]}';
}

class AUIPCInstruction extends Instruction {
  AUIPCInstruction(int rd, int immediate) : super([rd, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int currentPC = registers.getPC();
    int shiftedImmediate = operands[1] << 12;
    int result = currentPC + shiftedImmediate;
    registers.setGPR(operands[0], result);
    registers.incrementPC();
  }

  @override
  String toString() => 'AUIPC x${operands[0]}, ${operands[1]}';
}

class ADDIInstruction extends Instruction {
  ADDIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]);
    int immediateValue = (operands[2] << 20) >> 20;
    int result = rs1Value + immediateValue;
    registers.setGPR(operands[0], result);
    registers.incrementPC();
  }

  @override
  String toString() => 'ADDI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class SLTIInstruction extends Instruction {
  SLTIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]);
    int immediateValue = (operands[2] << 20) >> 20;
    int result = (rs1Value < immediateValue) ? 1 : 0;
    registers.setGPR(operands[0], result);
    registers.incrementPC();
  }

  @override
  String toString() => 'SLTI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class SLTIUInstruction extends Instruction {
  SLTIUInstruction(int rd, int rs1, int immediate)
      : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]) & 0xFFFFFFFF;
    int immediateValue = operands[2] & 0xFFF;
    int result = (rs1Value < immediateValue) ? 1 : 0;
    registers.setGPR(operands[0], result);
    registers.incrementPC();
  }

  @override
  String toString() => 'SLTIU x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class XORIInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register
  final int imm; // Immediate value

  XORIInstruction(this.rd, this.rs1, this.imm) : super([rd, rs1, imm]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);

    // Sign-extend the immediate value from 12 to 32 bits correctly
    // This operation fills the top 20 bits with the 12th bit of imm
    int signExtendedImm = (imm << 20) >> 20;

    // Perform the XOR operation
    int result = rs1Value ^ signExtendedImm;

    registers.setGPR(rd, result);
  }

  @override
  String toString() => 'XORI x$rd, x$rs1, $imm';
}

class XORInstruction extends Instruction {
  XORInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve values from the source registers
    int rs1Value = registers.getGPR(operands[1]);
    int rs2Value = registers.getGPR(operands[2]);

    // Perform bitwise XOR
    int result = rs1Value ^ rs2Value;

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'XOR x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class SRLInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register
  final int shamt; // Shift amount (immediate)

  SRLInstruction(this.rd, this.rs1, this.shamt) : super([rd, rs1, shamt]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    // Convert to unsigned and apply logical right shift
    int result = rs1Value.toUnsigned(32) >> shamt;
    // Store the result back as a signed integer
    registers.setGPR(rd, result.toSigned(32));
  }

  @override
  String toString() {
    return 'SRL x$rd, x$rs1, $shamt';
  }
}

class SRAInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register
  final int shamt; // Shift amount (immediate)

  SRAInstruction(this.rd, this.rs1, this.shamt) : super([rd, rs1, shamt]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    // Arithmetic right shift
    int result = rs1Value >> shamt;
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'SRA x$rd, x$rs1, $shamt';
  }
}

class ORInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register 1
  final int rs2; // Source register 2

  ORInstruction(this.rd, this.rs1, this.rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);
    int result = rs1Value | rs2Value;
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

  ANDInstruction(this.rd, this.rs1, this.rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(rs1);
    int rs2Value = registers.getGPR(rs2);
    int result = rs1Value & rs2Value;
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'AND x$rd, x$rs1, x$rs2';
  }
}

class LBInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Base address register
  final int offset; // Offset to add to the base address

  LBInstruction(this.rd, this.rs1, this.offset) : super([rd, rs1, offset]);

  @override
  void execute(Registers registers, Memory memory) {
    int baseAddress = registers.getGPR(rs1);
    int address = baseAddress + offset;
    int byte = memory.fetch(address);
    // Sign-extend the byte to 32 bits
    int result = (byte << 24) >> 24;
    registers.setGPR(rd, result);
  }

  @override
  String toString() {
    return 'LB x$rd, $offset(x$rs1)';
  }
}

class ORIInstruction extends Instruction {
  ORIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(operands[1]);

    // Sign-extend the 12-bit immediate value
    int signExtendedImmediate = (operands[2] << 20) >> 20;

    // Perform bitwise OR operation
    int result = rs1Value | signExtendedImmediate;

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'ORI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class ANDIInstruction extends Instruction {
  ANDIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]);
    int signExtendedImmediate = (operands[2] << 20) >> 20;
    int result = rs1Value & signExtendedImmediate;
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'ANDI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class SLLIInstruction extends Instruction {
  SLLIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(operands[1]);

    // Perform logical left shift operation
    int result = rs1Value << operands[2];

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SLLI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class SRLIInstruction extends Instruction {
  SRLIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(operands[1]);

    // Perform logical right shift operation
    int result = rs1Value >> operands[2];

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SRLI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class SRAIInstruction extends Instruction {
  SRAIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register
    int rs1Value = registers.getGPR(operands[1]);

    // Perform arithmetic right shift operation
    int result = rs1Value >> operands[2];
    if (rs1Value & (1 << 31) != 0) {
      // If the most significant bit is set
      result |= (~0 << (32 - operands[2])); // Set the upper bits
    }

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SRAI x${operands[0]}, x${operands[1]}, ${operands[2]}';
}

class ADDInstruction extends Instruction {
  ADDInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int result = registers.getGPR(operands[1]) + registers.getGPR(operands[2]);
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'ADD x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class SUBInstruction extends Instruction {
  SUBInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int result = registers.getGPR(operands[1]) - registers.getGPR(operands[2]);
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SUB x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class SLLInstruction extends Instruction {
  SLLInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    // Retrieve the value from the source register rs1
    int rs1Value = registers.getGPR(operands[1]);

    // Get the shift amount from the source register rs2 (only lower 5 bits are used)
    int shiftAmount = registers.getGPR(operands[2]) & 0x1F;

    // Perform logical left shift operation
    int result = rs1Value << shiftAmount;

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SLL x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class SLTInstruction extends Instruction {
  SLTInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]);
    int rs2Value = registers.getGPR(operands[2]);

    // Check if rs1Value is less than rs2Value
    int result = (rs1Value < rs2Value) ? 1 : 0;

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SLT x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class SLTUInstruction extends Instruction {
  SLTUInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    // Treat the register values as unsigned by using a mask
    int rs1Value = registers.getGPR(operands[1]) & 0xFFFFFFFF;
    int rs2Value = registers.getGPR(operands[2]) & 0xFFFFFFFF;

    // Check if rs1Value is less than rs2Value in unsigned comparison
    int result = (rs1Value < rs2Value) ? 1 : 0;

    // Store the result in the destination register
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SLTU x${operands[0]}, x${operands[1]}, x${operands[2]}';
}

class BEQInstruction extends Instruction {
  final int offset; // This is the immediate value shifted and sign-extended

  BEQInstruction(int rs1, int rs2, this.offset) : super([rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[0]);
    int rs2Value = registers.getGPR(operands[1]);

    if (rs1Value == rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + offset);
    }
  }

  @override
  String toString() => 'BEQ x${operands[0]}, x${operands[1]}, $offset';
}

class BGEInstruction extends Instruction {
  final int offset; // This is the immediate value shifted and sign-extended

  BGEInstruction(int rs1, int rs2, this.offset) : super([rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[0]);
    int rs2Value = registers.getGPR(operands[1]);

    if (rs1Value >= rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + offset);
    }
  }

  @override
  String toString() => 'BGE x${operands[0]}, x${operands[1]}, ${offset}';
}

class BNEInstruction extends Instruction {
  final int offset; // This is the immediate value shifted and sign-extended

  BNEInstruction(int rs1, int rs2, this.offset) : super([rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[0]);
    int rs2Value = registers.getGPR(operands[1]);

    if (rs1Value != rs2Value) {
      // Branch by setting the program counter to its current value + offset
      registers.setPC(registers.getPC() + offset);
    }
  }

  @override
  String toString() => 'BNE x${operands[0]}, x${operands[1]}, $offset';
}

class ECALLInstruction extends Instruction {
  ECALLInstruction() : super([]);

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
  FENCEInstruction() : super([]);

  @override
  void execute(Registers registers, Memory memory) {
    // For a simple emulation, the FENCE operation might not have any effect.
  }

  @override
  String toString() => 'FENCE';
}

class JALInstruction extends Instruction {
  final int rd; // Destination register to save the return address
  final int offset; // This is the immediate value shifted and sign-extended

  JALInstruction(this.rd, this.offset) : super([]);

  @override
  void execute(Registers registers, Memory memory) {
    int returnAddress =
        registers.getPC() + 4; // Address of the next instruction
    registers.setGPR(rd, returnAddress); // Save return address in rd

    // Jump by setting the program counter to its current value + offset
    registers.setPC(registers.getPC() + offset);
  }

  @override
  String toString() => 'JAL x$rd, $offset';
}

class SWInstruction extends Instruction {
  final int rs1; // Source register 1 (base address)
  final int rs2; // Source register 2 (data to store)
  final int offset; // 12-bit signed offset

  SWInstruction(this.rs1, this.rs2, this.offset) : super([]);

  @override
  void execute(Registers registers, Memory memory) {
    int address = registers.getGPR(rs1) + offset; // Calculate memory address
    int valueToStore = registers.getGPR(rs2); // Get data from rs2

    memory.store(address, valueToStore); // Store the word in memory
  }

  @override
  String toString() => 'SW x$rs2, x$rs1, $offset';
}

class CSRRSInstruction extends Instruction {
  final int rd; // Destination register
  final int rs1; // Source register (can be x0)
  final int csr; // CSR register index

  CSRRSInstruction(this.rd, this.rs1, this.csr) : super([rd, rs1, csr]);

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

  CSRRWIInstruction(this.rd, this.csr, this.zimm) : super([]);

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

  CSRRWInstruction(this.rd, this.csr, this.rs1) : super([]);

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
