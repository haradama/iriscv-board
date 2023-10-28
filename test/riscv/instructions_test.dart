import 'package:flutter_test/flutter_test.dart';
import 'package:iriscv_board/riscv/instructions.dart';
import 'package:iriscv_board/riscv/memory.dart';
import 'package:iriscv_board/riscv/registers.dart';

void main() {
  group('LUIInstruction Tests', () {
    late Registers registers;
    late Memory memory;
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LUI correctly loads a 20-bit immediate into the upper 20 bits', () {
      var instruction =
          LUIInstruction(1, 0x12345); // rd = x1, immediate = 0x12345
      instruction.execute(registers, memory);
      expect(registers.getGPR(1), 0x12345000);
    });

    test('LUI should clear the lower 12 bits', () {
      var instruction =
          LUIInstruction(2, 0xFFFFF); // rd = x2, immediate = 0xFFFFF
      instruction.execute(registers, memory);
      expect(registers.getGPR(2), 0xFFFFF000);
    });
  });

  group('AUIPCInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('AUIPC correctly adds shifted immediate to PC', () {
      registers.setPC(0x100);
      var instruction =
          AUIPCInstruction(1, 0x12345); // rd = x1, immediate = 0x12345
      instruction.execute(registers, memory);
      expect(registers.getGPR(1), 0x12345100);
    });

    test('AUIPC correctly updates PC', () {
      registers.setPC(0x100); // Setting PC to an arbitrary value
      var instruction = AUIPCInstruction(1, 0x12345);
      instruction.execute(registers, memory);
      expect(registers.getPC(), 0x104);
    });
  });

  group('ADDIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('ADDI correctly adds positive immediate to register value', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = ADDIInstruction(2, 1, 5); // ADDI x2, x1, 5
      instruction.execute(registers, memory);
      expect(registers.getGPR(2), 15);
    });

    test('ADDI correctly adds negative immediate to register value', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = ADDIInstruction(2, 1, -5); // ADDI x2, x1, -5
      instruction.execute(registers, memory);
      expect(registers.getGPR(2), 5);
    });

    test('ADDI correctly updates PC', () {
      var instruction = ADDIInstruction(2, 1, 5);
      instruction.execute(registers, memory);
      expect(registers.getPC(), 4);
    });
  });

  group('SLTIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SLTI correctly sets rd to 1 when rs1 value is less than immediate',
        () {
      registers.setGPR(1, 4); // Setting x1 to 4
      var instruction = SLTIInstruction(2, 1, 5); // SLTI x2, x1, 5
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (because 4 < 5)
      expect(registers.getGPR(2), 1);
    });

    test(
        'SLTI correctly sets rd to 0 when rs1 value is not less than immediate',
        () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = SLTIInstruction(2, 1, 5); // SLTI x2, x1, 5
      instruction.execute(registers, memory);

      // x2 should now hold the value 0 (because 10 >= 5)
      expect(registers.getGPR(2), 0);
    });

    test('SLTI correctly handles negative immediate values', () {
      registers.setGPR(1, -10); // Setting x1 to -10
      var instruction = SLTIInstruction(2, 1, -5); // SLTI x2, x1, -5
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (because -10 < -5)
      expect(registers.getGPR(2), 1);
    });

    test('SLTI correctly updates PC', () {
      var instruction = SLTIInstruction(2, 1, 5);
      instruction.execute(registers, memory);

      // Assuming 32-bit instructions, the PC should now be incremented by 4
      expect(registers.getPC(), 4);
    });
  });

  group('SLTIUInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test(
        'SLTIU correctly sets rd to 1 when rs1 unsigned value is less than immediate',
        () {
      registers.setGPR(1, 4); // Setting x1 to 4
      var instruction = SLTIUInstruction(2, 1, 5); // SLTIU x2, x1, 5
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (because unsigned 4 < 5)
      expect(registers.getGPR(2), 1);
    });

    test(
        'SLTIU correctly sets rd to 0 when rs1 unsigned value is not less than immediate',
        () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = SLTIUInstruction(2, 1, 5); // SLTIU x2, x1, 5
      instruction.execute(registers, memory);

      // x2 should now hold the value 0 (because unsigned 10 >= 5)
      expect(registers.getGPR(2), 0);
    });

    test(
        'SLTIU correctly handles comparison with negative rs1 value (treated as large unsigned)',
        () {
      registers.setGPR(1, -1); // Setting x1 to -1
      var instruction = SLTIUInstruction(2, 1, 5); // SLTIU x2, x1, 5
      instruction.execute(registers, memory);

      // x2 should now hold the value 0, because -1 as unsigned (0xFFFFFFFF) is greater than 5
      expect(registers.getGPR(2), 0);
    });

    test('SLTIU correctly updates PC', () {
      var instruction = SLTIUInstruction(2, 1, 5);
      instruction.execute(registers, memory);

      // Assuming 32-bit instructions, the PC should now be incremented by 4
      expect(registers.getPC(), 4);
    });
  });

  group('XORIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test(
        'XORI correctly computes bitwise XOR of a positive integer and positive immediate',
        () {
      registers.setGPR(1, 5); // Setting x1 to 5 (binary: 101)
      var instruction = XORIInstruction(2, 1, 3); // XORI x2, x1, 3 (binary: 11)
      instruction.execute(registers, memory);

      // x2 should now hold the value 6 (binary: 110)
      expect(registers.getGPR(2), 6);
    });

    test(
        'XORI correctly computes bitwise XOR of a negative integer and negative immediate',
        () {
      registers.setGPR(1, -5); // Setting x1 to -5 (binary: ...1111111111111011)
      var instruction = XORIInstruction(
          2, 1, -3); // XORI x2, x1, -3 (binary: ...1111111111111101)
      instruction.execute(registers, memory);

      // Result will be ...0000000000000010 (binary) = 2
      expect(registers.getGPR(2), 2);
    });

    test('XORI correctly computes bitwise XOR with zero immediate', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = XORIInstruction(2, 1, 0); // XORI x2, x1, 0 (binary: 00)
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1 because XOR with 0 doesn't change the value
      expect(registers.getGPR(2), 7);
    });

    test('XORI correctly handles sign-extended immediates', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      var instruction = XORIInstruction(
          2, 1, 0xFFF); // XORI x2, x1, 0xFFF (-1 when sign-extended)
      instruction.execute(registers, memory);

      // Result should be bitwise XOR with -1, which flips all the bits of x1
      expect(registers.getGPR(2), -6);
    });
  });

  group('ORIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test(
        'ORI correctly computes bitwise OR of a positive integer and positive immediate',
        () {
      registers.setGPR(1, 5); // Setting x1 to 5 (binary: 101)
      var instruction = ORIInstruction(2, 1, 3); // ORI x2, x1, 3 (binary: 11)
      instruction.execute(registers, memory);

      // x2 should now hold the value 7 (binary: 111)
      expect(registers.getGPR(2), 7);
    });

    test(
        'ORI correctly computes bitwise OR of a negative integer and negative immediate',
        () {
      registers.setGPR(1, -5); // Setting x1 to -5 (binary: ...1111111111111011)
      var instruction = ORIInstruction(
          2, 1, -3); // ORI x2, x1, -3 (binary: ...1111111111111101)
      instruction.execute(registers, memory);

      // Result will be ...1111111111111111 (binary) = -1
      expect(registers.getGPR(2), -1);
    });

    test('ORI correctly computes bitwise OR with zero immediate', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = ORIInstruction(2, 1, 0); // ORI x2, x1, 0 (binary: 00)
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1 because OR with 0 doesn't change the value
      expect(registers.getGPR(2), 7);
    });

    test('ORI correctly handles sign-extended immediates', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      var instruction = ORIInstruction(
          2, 1, 0xFFF); // ORI x2, x1, 0xFFF (-1 when sign-extended)
      instruction.execute(registers, memory);

      // Result should be 5 | -1, which is -1 (as OR with -1 sets all bits to 1)
      expect(registers.getGPR(2), -1);
    });
  });

  group('ANDIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test(
        'ANDI correctly computes bitwise AND of a positive integer and positive immediate',
        () {
      registers.setGPR(1, 5); // Setting x1 to 5 (binary: 101)
      var instruction = ANDIInstruction(2, 1, 3); // ANDI x2, x1, 3 (binary: 11)
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (binary: 001)
      expect(registers.getGPR(2), 1);
    });

    test(
        'ANDI correctly computes bitwise AND of a negative integer and negative immediate',
        () {
      registers.setGPR(1, -5); // Setting x1 to -5 (binary: ...1111111111111011)
      var instruction = ANDIInstruction(
          2, 1, -3); // ANDI x2, x1, -3 (binary: ...1111111111111101)
      instruction.execute(registers, memory);

      // Result will be ...0000000000000001 (binary) = 1
      expect(registers.getGPR(2), 1);
    });

    test('ANDI correctly computes bitwise AND with zero immediate', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = ANDIInstruction(2, 1, 0); // ANDI x2, x1, 0 (binary: 00)
      instruction.execute(registers, memory);

      // x2 should now hold the value 0 because AND with 0 results in 0
      expect(registers.getGPR(2), 0);
    });

    test('ANDI correctly handles sign-extended immediates', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      var instruction = ANDIInstruction(
          2, 1, 0xFFF); // ANDI x2, x1, 0xFFF (-1 when sign-extended)
      instruction.execute(registers, memory);

      // Result should be 5 & -1, which is 5 (as AND with -1 doesn't change the value)
      expect(registers.getGPR(2), 5);
    });
  });

  group('SLLIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SLLI correctly performs left shift', () {
      registers.setGPR(1, 5); // Setting x1 to 5 (binary: 101)
      var instruction = SLLIInstruction(2, 1, 2); // SLLI x2, x1, 2
      instruction.execute(registers, memory);

      // x2 should now hold the value 20 (binary: 10100)
      expect(registers.getGPR(2), 20);
    });

    test('SLLI with zero shift amount leaves the value unchanged', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = SLLIInstruction(2, 1, 0); // SLLI x2, x1, 0
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1
      expect(registers.getGPR(2), 7);
    });
  });

  group('SRLIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SRLI correctly performs logical right shift', () {
      registers.setGPR(1, 20); // Setting x1 to 20 (binary: 10100)
      var instruction = SRLIInstruction(2, 1, 2); // SRLI x2, x1, 2
      instruction.execute(registers, memory);

      // x2 should now hold the value 5 (binary: 101)
      expect(registers.getGPR(2), 5);
    });

    test('SRLI with zero shift amount leaves the value unchanged', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = SRLIInstruction(2, 1, 0); // SRLI x2, x1, 0
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1
      expect(registers.getGPR(2), 7);
    });
  });

  group('SRAIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SRAI correctly performs arithmetic right shift on positive values',
        () {
      registers.setGPR(1, 20); // Setting x1 to 20 (binary: 10100)
      var instruction = SRAIInstruction(2, 1, 2); // SRAI x2, x1, 2
      instruction.execute(registers, memory);

      // x2 should now hold the value 5 (binary: 101)
      expect(registers.getGPR(2), 5);
    });

    test('SRAI correctly performs arithmetic right shift on negative values',
        () {
      registers.setGPR(1, -5); // Setting x1 to -5 (binary: ...1111111111111011)
      var instruction = SRAIInstruction(2, 1, 1); // SRAI x2, x1, 1
      instruction.execute(registers, memory);

      // x2 should now hold the value -3 (binary: ...1111111111111101)
      expect(registers.getGPR(2), -3);
    });

    test('SRAI with zero shift amount leaves the value unchanged', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      var instruction = SRAIInstruction(2, 1, 0); // SRAI x2, x1, 0
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1
      expect(registers.getGPR(2), 7);
    });
  });

  group('ADDInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('ADD instruction correctly adds two positive numbers', () {
      registers.setGPR(1, 5); // rs1 = 5
      registers.setGPR(2, 3); // rs2 = 3
      var instruction = ADDInstruction(3, 1, 2); // rd = x3, rs1 = x1, rs2 = x2
      instruction.execute(registers, memory);

      expect(registers.getGPR(3), 8); // x3 should be 8
    });

    test('ADD instruction correctly adds a positive and a negative number', () {
      registers.setGPR(1, -5); // rs1 = -5
      registers.setGPR(2, 3); // rs2 = 3
      var instruction = ADDInstruction(3, 1, 2);
      instruction.execute(registers, memory);

      expect(registers.getGPR(3), -2); // x3 should be -2
    });
  });

  group('SUBInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SUB correctly subtracts two positive numbers', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      registers.setGPR(3, 5); // Setting x3 to 5
      var instruction = SUBInstruction(2, 1, 3); // SUB x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 5 (10 - 5)
      expect(registers.getGPR(2), 5);
    });

    test('SUB correctly subtracts a positive and a negative number', () {
      registers.setGPR(1, 7); // Setting x1 to 7
      registers.setGPR(3, -3); // Setting x3 to -3
      var instruction = SUBInstruction(2, 1, 3); // SUB x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 10 (7 - (-3))
      expect(registers.getGPR(2), 10);
    });

    test('SUB correctly subtracts two negative numbers', () {
      registers.setGPR(1, -7); // Setting x1 to -7
      registers.setGPR(3, -3); // Setting x3 to -3
      var instruction = SUBInstruction(2, 1, 3); // SUB x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value -4 (-7 - (-3))
      expect(registers.getGPR(2), -4);
    });

    test('SUB with rs1 = 0 subtracts the value of rs2 from 0', () {
      registers.setGPR(1, 0); // Setting x1 to 0
      registers.setGPR(3, 5); // Setting x3 to 5
      var instruction = SUBInstruction(2, 1, 3); // SUB x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value -5 (0 - 5)
      expect(registers.getGPR(2), -5);
    });
  });
  group('SLLInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SLL correctly performs left shift', () {
      registers.setGPR(1, 5); // Setting x1 to 5 (binary: 101)
      registers.setGPR(3, 2); // Setting shift amount in x3 to 2
      var instruction = SLLInstruction(2, 1, 3); // SLL x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 20 (binary: 10100)
      expect(registers.getGPR(2), 20);
    });

    test('SLL with zero shift amount leaves the value unchanged', () {
      registers.setGPR(1, 7); // Setting x1 to 7 (binary: 111)
      registers.setGPR(3, 0); // Setting shift amount in x3 to 0
      var instruction = SLLInstruction(2, 1, 3); // SLL x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1
      expect(registers.getGPR(2), 7);
    });
  });

  group('SLTInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SLT correctly sets rd when rs1 is less than rs2', () {
      registers.setGPR(1, 3); // Setting x1 to 3
      registers.setGPR(3, 5); // Setting x3 to 5
      var instruction = SLTInstruction(2, 1, 3); // SLT x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (since 3 < 5)
      expect(registers.getGPR(2), 1);
    });

    test('SLT correctly sets rd when rs1 is not less than rs2', () {
      registers.setGPR(1, 7); // Setting x1 to 7
      registers.setGPR(3, 4); // Setting x3 to 4
      var instruction = SLTInstruction(2, 1, 3); // SLT x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 0 (since 7 is not < 4)
      expect(registers.getGPR(2), 0);
    });

    test('SLT correctly handles negative numbers', () {
      registers.setGPR(1, -7); // Setting x1 to -7
      registers.setGPR(3, -3); // Setting x3 to -3
      var instruction = SLTInstruction(2, 1, 3); // SLT x2, x1, x3
      instruction.execute(registers, memory);

      // x2 should now hold the value 1 (since -7 < -3)
      expect(registers.getGPR(2), 1);
    });
  });
}
