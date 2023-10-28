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

class AddInstruction extends Instruction {
  AddInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int result = registers.getGPR(operands[1]) + registers.getGPR(operands[2]);
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'ADD x${operands[0]}, x${operands[1]}, x${operands[2]}';
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

class SubInstruction extends Instruction {
  SubInstruction(int rd, int rs1, int rs2) : super([rd, rs1, rs2]);

  @override
  void execute(Registers registers, Memory memory) {
    int result = registers.getGPR(operands[1]) - registers.getGPR(operands[2]);
    registers.setGPR(operands[0], result);
  }

  @override
  String toString() => 'SUB x${operands[0]}, x${operands[1]}, x${operands[2]}';
}
