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
  XORIInstruction(int rd, int rs1, int immediate) : super([rd, rs1, immediate]);

  @override
  void execute(Registers registers, Memory memory) {
    int rs1Value = registers.getGPR(operands[1]);
    int signExtendedImmediate = (operands[2] << 20) >> 20;
    int result = rs1Value ^ signExtendedImmediate;
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'XORI x${operands[0]}, x${operands[1]}, ${operands[2]}';
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
