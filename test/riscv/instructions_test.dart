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

    test('LUI correctly loads immediate into upper 20 bits of register', () {
      const int imm = 0x12345; // 20-bit immediate
      var instruction = LUIInstruction(1, imm); // LUI x1, 0x12345
      instruction.execute(registers, memory);

      // The result in x1 should be the immediate shifted left by 12 bits
      expect(registers.getGPR(1), imm << 12);
    });

    test('LUI sets the lower 12 bits of register to zeros', () {
      const int imm = 0x12345; // 20-bit immediate
      var instruction = LUIInstruction(1, imm); // LUI x1, 0x12345
      instruction.execute(registers, memory);

      // The lower 12 bits of x1 should be zero
      expect(registers.getGPR(1) & 0xFFF, 0);
    });

    test('LUI handles the sign extension of immediate', () {
      const int imm =
          0xFFFFF; // A 20-bit immediate that would be negative if sign-extended
      var instruction = LUIInstruction(1, imm); // LUI x1, 0xFFFFF
      instruction.execute(registers, memory);

      // The result in x1 should be the immediate shifted left by 12 bits, treated as a signed 32-bit integer
      int expectedResult = (imm << 12).toSigned(32);
      expect(registers.getGPR(1), expectedResult);
    });
  });

  group('AUIPCInstruction Tests', () {
    test('Minimum valid rd', () {
      var instruction = AUIPCInstruction(0, 1024);
      // Execute and expect functionalities
      // You would assert the expected outcomes after execution
      expect(instruction.rd, equals(0));
    });

    test('Just above minimum valid rd', () {
      var instruction = AUIPCInstruction(1, 1024);
      expect(instruction.rd, equals(1));
    });

    test('Just below maximum valid rd', () {
      var instruction = AUIPCInstruction(30, 1024);
      expect(instruction.rd, equals(30));
    });

    test('Maximum valid rd', () {
      var instruction = AUIPCInstruction(31, 1024);
      expect(instruction.rd, equals(31));
    });

    test('Minimum valid imm', () {
      var instruction = AUIPCInstruction(10, -524288);
      expect(instruction.imm, equals(-524288));
    });

    test('Just above minimum valid imm', () {
      var instruction = AUIPCInstruction(10, -524287);
      expect(instruction.imm, equals(-524287));
    });

    test('Just below maximum valid imm', () {
      var instruction = AUIPCInstruction(10, 524287);
      expect(instruction.imm, equals(524287));
    });

    test('Maximum valid imm', () {
      var instruction = AUIPCInstruction(10, 524288);
      expect(instruction.imm, equals(524288));
    });

    test('Zero imm', () {
      var instruction = AUIPCInstruction(10, 0);
      expect(instruction.imm, equals(0));
    });

    test('Typical positive imm', () {
      var instruction = AUIPCInstruction(10, 1024);
      expect(instruction.imm, equals(1024));
    });

    test('Typical negative imm', () {
      var instruction = AUIPCInstruction(10, -1024);
      expect(instruction.imm, equals(-1024));
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

      // x2 should now hold the value 6 (binary: 110)
      expect(registers.getGPR(2), 6);
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
      var instruction = XORIInstruction(2, 1, -1); // XORI x2, x1, -1
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
      var instruction = ORIInstruction(2, 1, -1); // ORI x2, x1, -1
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

      expect(registers.getGPR(2), -7);
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

  group('BEQInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('BEQ branches when rs1 equals rs2', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = BEQInstruction(1, 2, 4); // BEQ x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should be advanced by the offset
      expect(registers.getPC(), initialPC + 4);
    });

    test('BEQ does not branch when rs1 is not equal to rs2', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      registers.setGPR(2, 6); // Setting x2 to 6
      var instruction = BEQInstruction(1, 2, 4); // BEQ x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should remain unchanged
      expect(registers.getPC(), initialPC);
    });
  });

  group('BGEInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('BGE branches when rs1 is greater than rs2', () {
      registers.setGPR(1, 6); // Setting x1 to 6
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = BGEInstruction(1, 2, 4); // BGE x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should be advanced by the offset
      expect(registers.getPC(), initialPC + 4);
    });

    test('BGE branches when rs1 is equal to rs2', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = BGEInstruction(1, 2, 4); // BGE x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should be advanced by the offset
      expect(registers.getPC(), initialPC + 4);
    });

    test('BGE does not branch when rs1 is less than rs2', () {
      registers.setGPR(1, 4); // Setting x1 to 4
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = BGEInstruction(1, 2, 4); // BGE x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should remain unchanged
      expect(registers.getPC(), initialPC);
    });
  });

  group('BNEInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('BNE branches when rs1 is not equal to rs2', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      registers.setGPR(2, 6); // Setting x2 to 6
      var instruction = BNEInstruction(1, 2, 4); // BNE x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should be advanced by the offset
      expect(registers.getPC(), initialPC + 4);
    });

    test('BNE does not branch when rs1 is equal to rs2', () {
      registers.setGPR(1, 5); // Setting x1 to 5
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = BNEInstruction(1, 2, 4); // BNE x1, x2, offset 4
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should remain unchanged
      expect(registers.getPC(), initialPC);
    });
  });

  group('ECALLInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('ECALL throws an exception when executed', () {
      var instruction = ECALLInstruction();
      // Expect the execute method to throw an exception
      expect(() => instruction.execute(registers, memory),
          throwsA(isA<Exception>()));
    });
  });

  group('FENCEInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('FENCE does not throw an exception when executed', () {
      var instruction = FENCEInstruction();
      // Expect the execute method to complete without throwing
      expect(() => instruction.execute(registers, memory), returnsNormally);
    });
  });

  group('JALInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('JAL jumps to the correct address and sets return address', () {
      var instruction = JALInstruction(1, 8); // JAL x1, offset 8
      int initialPC = registers.getPC();
      instruction.execute(registers, memory);

      // Program counter should be advanced by the offset
      expect(registers.getPC(), initialPC + 8);

      // x1 (or ra) should contain the address of the instruction following JAL
      expect(registers.getGPR(1), initialPC + 4);
    });
  });

  group('SWInstruction Tests', () {
    late Registers registers;
    late Memory memory;
    const baseAddress = 100; // An arbitrary base address for the test

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SW stores a word in the correct memory location', () {
      const valueToStore = 0x1; // An arbitrary value to store
      const offset = 0; // Use a zero offset for simplicity
      registers.setGPR(1, baseAddress); // Set rs1 to baseAddress
      registers.setGPR(2, valueToStore); // Set rs2 to valueToStore
      var instruction = SWInstruction(1, 2, offset);
      instruction.execute(registers, memory);

      // Fetch the stored value from memory
      int storedValue = memory.fetch(baseAddress);

      // The stored value should match valueToStore
      expect(storedValue, equals(valueToStore));
    });
  });

  group('CSRRSInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('CSRRS reads CSR and sets bits if rs1 is not x0', () {
      registers.setCSR(0x305, 0x55); // Arbitrary CSR and value
      registers.setGPR(1, 0xAA); // rs1 with a value that will modify CSR
      var instruction = CSRRSInstruction(2, 1, 0x305); // CSRRS x2, 0x305, x1
      instruction.execute(registers, memory);

      // The result in rd (x2) should be the original value of the CSR
      expect(registers.getGPR(2), 0x55);

      // The CSR should now be updated with the bits from rs1 set
      expect(registers.getCSR(0x305), 0xFF);
    });

    test('CSRRS does not modify CSR if rs1 is x0', () {
      registers.setCSR(0x305, 0x55); // Arbitrary CSR and value
      var instruction = CSRRSInstruction(2, 0, 0x305); // CSRRS x2, 0x305, x0
      instruction.execute(registers, memory);

      // The result in rd (x2) should be the original value of the CSR
      expect(registers.getGPR(2), 0x55);

      // The CSR should remain unchanged
      expect(registers.getCSR(0x305), 0x55);
    });
  });

  group('CSRRWIInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('CSRRWI reads CSR value and writes immediate to CSR', () {
      // Assuming CSR with index 773 for demonstration (equivalent to 0x305)
      registers.setCSR(773, 10); // Set initial value for CSR
      var instruction = CSRRWIInstruction(2, 773, 12); // CSRRWI x2, 773, 12

      instruction.execute(registers, memory);

      // Check if rd has the initial CSR value
      expect(registers.getGPR(2), 10);

      // Check if CSR has been set to the immediate value
      expect(registers.getCSR(773), 12);
    });
  });

  group('CSRRWInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('CSRRW reads CSR value and writes GPR value to CSR', () {
      // Assuming CSR with index 773 for demonstration
      registers.setCSR(773, 50); // Set initial value for CSR
      registers.setGPR(5, 100); // Set value for source register x5

      var instruction = CSRRWInstruction(2, 773, 5); // CSRRW x2, 773, x5

      instruction.execute(registers, memory);

      // Check if rd has the initial CSR value
      expect(registers.getGPR(2), 50);

      // Check if CSR has been set to the source register value
      expect(registers.getCSR(773), 100);
    });
  });

  group('XORInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    // Setup before each test
    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('XOR correctly computes bitwise XOR of two positive integers', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      registers.setGPR(2, 12); // Setting x2 to 12
      var instruction = XORInstruction(3, 1, 2); // XOR x3, x1, x2
      instruction.execute(registers, memory);

      // x3 should now hold the value 6
      expect(registers.getGPR(3), 6);
    });

    test('XOR correctly computes bitwise XOR of two identical numbers', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = XORInstruction(2, 1, 1); // XOR x2, x1, x1
      instruction.execute(registers, memory);

      // x2 should now hold the value 0, as XOR with itself should result in 0
      expect(registers.getGPR(2), 0);
    });

    test('XOR correctly computes bitwise XOR with zero', () {
      registers.setGPR(1, 10); // Setting x1 to 10
      var instruction = XORInstruction(2, 1, 0); // XOR x2, x1, x0
      instruction.execute(registers, memory);

      // x2 should now hold the same value as x1 because XOR with 0 doesn't change the value
      expect(registers.getGPR(2), 10);
    });

    test('XOR correctly handles sign extension', () {
      registers.setGPR(1, -1); // Setting x1 to -1 (all bits set)
      registers.setGPR(2, 170); // Setting x2 to 170
      var instruction = XORInstruction(3, 1, 2); // XOR x3, x1, x2
      instruction.execute(registers, memory);

      // Result should be -1 XOR 170, which flips all bits of 170
      // The expected result is the bitwise NOT of 170
      expect(registers.getGPR(3), ~170);
    });
  });

  group('SRLInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SRL correctly shifts a positive integer', () {
      registers.setGPR(1, 20); // Setting x1 to 20
      var instruction = SRLInstruction(2, 1, 2); // SRL x2, x1, 2
      instruction.execute(registers, memory);

      // After shifting 20 right by 2, x2 should hold 5
      expect(registers.getGPR(2), 5);
    });

    test('SRL correctly shifts with zero', () {
      registers.setGPR(1, 20); // Setting x1 to 20
      var instruction = SRLInstruction(2, 1, 0); // SRL x2, x1, 0
      instruction.execute(registers, memory);

      // Shifting by 0 should have no effect; x2 should hold the original value
      expect(registers.getGPR(2), 20);
    });

    test('SRL correctly shifts a negative integer', () {
      registers.setGPR(1, -1); // Setting x1 to -1 (all bits set)
      var instruction = SRLInstruction(2, 1, 1); // SRL x2, x1, 1
      instruction.execute(registers, memory);

      // After shifting -1 right by 1, the result should be 0x7FFFFFFF (since this is a logical shift)
      expect(registers.getGPR(2), 0x7FFFFFFF);
    });
  });

  group('SRAInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SRA correctly shifts a positive integer', () {
      registers.setGPR(1, 80); // Setting x1 to 80
      var instruction = SRAInstruction(2, 1, 2); // SRA x2, x1, 2
      instruction.execute(registers, memory);

      // After shifting 80 right by 2, x2 should hold 20
      expect(registers.getGPR(2), 20);
    });

    test('SRA correctly shifts with zero', () {
      registers.setGPR(1, 80); // Setting x1 to 80
      var instruction = SRAInstruction(2, 1, 0); // SRA x2, x1, 0
      instruction.execute(registers, memory);

      // Shifting by 0 should have no effect; x2 should hold the original value
      expect(registers.getGPR(2), 80);
    });

    test('SRA correctly shifts a negative integer', () {
      registers.setGPR(1, -80); // Setting x1 to -80
      var instruction = SRAInstruction(2, 1, 2); // SRA x2, x1, 2
      instruction.execute(registers, memory);

      // After shifting -80 right by 2, x2 should hold -20
      expect(registers.getGPR(2), -20);
    });
  });

  group('ORInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('OR correctly computes bitwise OR of two integers', () {
      registers.setGPR(1, 12); // Setting x1 to 12
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = ORInstruction(3, 1, 2); // OR x3, x1, x2
      instruction.execute(registers, memory);

      // After OR operation of 12 (1100) and 5 (0101), x3 should hold 13 (1101)
      expect(registers.getGPR(3), 13);
    });

    test('OR correctly computes bitwise OR when one register is zero', () {
      registers.setGPR(1, 0); // Setting x1 to 0
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = ORInstruction(3, 1, 2); // OR x3, x1, x2
      instruction.execute(registers, memory);

      // OR operation with 0 should give the other operand, x3 should hold 5
      expect(registers.getGPR(3), 5);
    });

    test('OR correctly computes bitwise OR when both registers are zero', () {
      registers.setGPR(1, 0); // Setting x1 to 0
      registers.setGPR(2, 0); // Setting x2 to 0
      var instruction = ORInstruction(3, 1, 2); // OR x3, x1, x2
      instruction.execute(registers, memory);

      // OR operation of both zeros should result in zero, x3 should hold 0
      expect(registers.getGPR(3), 0);
    });
  });

  group('ANDInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('AND correctly computes bitwise AND of two integers', () {
      registers.setGPR(1, 12); // Setting x1 to 12
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = ANDInstruction(3, 1, 2); // AND x3, x1, x2
      instruction.execute(registers, memory);

      // After AND operation of 12 (1100) and 5 (0101), x3 should hold 4 (0100)
      expect(registers.getGPR(3), 4);
    });

    test('AND correctly computes bitwise AND when one register is zero', () {
      registers.setGPR(1, 0); // Setting x1 to 0
      registers.setGPR(2, 5); // Setting x2 to 5
      var instruction = ANDInstruction(3, 1, 2); // AND x3, x1, x2
      instruction.execute(registers, memory);

      // AND operation with 0 should give 0, x3 should hold 0
      expect(registers.getGPR(3), 0);
    });

    test('AND correctly computes bitwise AND when both registers are zero', () {
      registers.setGPR(1, 0); // Setting x1 to 0
      registers.setGPR(2, 0); // Setting x2 to 0
      var instruction = ANDInstruction(3, 1, 2); // AND x3, x1, x2
      instruction.execute(registers, memory);

      // AND operation of both zeros should result in zero, x3 should hold 0
      expect(registers.getGPR(3), 0);
    });
  });

  group('LBInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LB correctly loads a positive byte', () {
      const int address = 0x100;
      const int byteValue = 0x7F; // 127 in decimal
      memory.storeByte(address, byteValue);
      var instruction = LBInstruction(2, 1, 0); // LB x2, 0(x1)
      registers.setGPR(1, address); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded byte is correct
      expect(registers.getGPR(2), byteValue);
    });

    test('LB correctly loads a negative byte and sign-extends it', () {
      const int address = 0x100;
      const int byteValue = -128;
      memory.storeByte(address, byteValue);
      var instruction = LBInstruction(2, 1, 0); // LB x2, 0(x1)
      registers.setGPR(1, address); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded byte is sign-extended correctly
      expect(registers.getGPR(2), -128);
    });

    test('LB correctly loads a byte using an offset', () {
      const int baseAddress = 0x100;
      const int offset = 0x4;
      const int byteValue = 0x7F; // 127 in decimal
      memory.storeByte(baseAddress + offset, byteValue);
      var instruction = LBInstruction(2, 1, offset); // LB x2, 4(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded byte from the correct offset is correct
      expect(registers.getGPR(2), byteValue);
    });
  });

  group('LHInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LH correctly loads a positive halfword', () {
      const int address = 0x100;
      const int halfwordValue = 32767; // Largest positive 16-bit signed integer
      memory.storeHalfword(address, halfwordValue);
      var instruction = LHInstruction(2, 1, 0); // LH x2, 0(x1)
      registers.setGPR(1, address); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded halfword is correct
      expect(registers.getGPR(2), halfwordValue);
    });

    test('LH correctly loads a negative halfword and sign-extends it', () {
      const int address = 0x100;
      const int halfwordValue =
          -32768; // Smallest negative 16-bit signed integer
      memory.storeHalfword(address, halfwordValue);
      var instruction = LHInstruction(2, 1, 0); // LH x2, 0(x1)
      registers.setGPR(1, address); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded halfword is sign-extended correctly
      expect(registers.getGPR(2), halfwordValue);
    });

    test('LH correctly loads a halfword using an offset', () {
      const int baseAddress = 0x100;
      const int offset = 2;
      const int halfwordValue = 32767; // Largest positive 16-bit signed integer
      memory.storeHalfword(baseAddress + offset, halfwordValue);
      var instruction = LHInstruction(2, 1, offset); // LH x2, 2(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded halfword from the correct offset is correct
      expect(registers.getGPR(2), halfwordValue);
    });
  });

  group('LWInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LW correctly loads a word from memory', () {
      const int baseAddress = 0x04;
      const int testValue = 0x12345678; // Arbitrary 32-bit value
      memory.store(baseAddress, testValue);
      var lwInstruction = LWInstruction(2, 1, 0); // LW x2, 0(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      lwInstruction.execute(registers, memory);

      // Check if x2 now holds the value loaded from memory
      expect(registers.getGPR(2), testValue);
    });

    test('LW uses the correct offset', () {
      const int baseAddress = 0x100;
      const int offset = 0x04;
      const int testValue = 0x1; // Arbitrary 32-bit value
      memory.store(baseAddress + offset, testValue);
      var lwInstruction = LWInstruction(2, 1, offset); // LW x2, offset(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      lwInstruction.execute(registers, memory);

      // Check if x2 now holds the value loaded from the correct offset
      expect(registers.getGPR(2), testValue);
    });
  });

  group('LBUInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LBU correctly loads an unsigned byte', () {
      const int address = 0x04;
      const int byteValue = 127;
      memory.storeByte(address, byteValue);
      var lbuInstruction = LBUInstruction(1, 0, address); // LBU x1, address(x0)
      registers.setGPR(0, 0); // Base address is 0, stored in x0

      lbuInstruction.execute(registers, memory);

      // x1 should now hold the value 127 since LBU zero-extends
      expect(registers.getGPR(1), byteValue);
    });

    test('LBU correctly loads a byte using an offset', () {
      const int baseAddress = 0x100;
      const int offset = 0x4;
      const int byteValue = 0x7F; // 127 in decimal
      memory.storeByte(baseAddress + offset, byteValue);
      var instruction = LBUInstruction(2, 1, offset); // LBU x2, 4(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded byte from the correct offset is correct and is zero-extended
      expect(registers.getGPR(2), byteValue);
    });
  });

  group('JALRInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('JALR sets the program counter to the target address', () {
      const int baseAddress = 0x100;
      const int offset = 4;
      const int currentPC = 0x80; // Current program counter value
      registers.setPC(currentPC);
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      var jalrInstruction =
          JALRInstruction(2, 1, offset); // JALR x2, x1, offset
      jalrInstruction.execute(registers, memory);

      // Check if the program counter is set correctly
      expect(registers.getPC(), baseAddress + offset & ~1);
    });

    test('JALR stores the return address in the destination register', () {
      const int baseAddress = 0x100;
      const int offset = 4;
      const int currentPC = 0x80; // Current program counter value
      registers.setPC(currentPC);
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      var jalrInstruction =
          JALRInstruction(2, 1, offset); // JALR x2, x1, offset
      jalrInstruction.execute(registers, memory);

      // Check if the return address is stored in the destination register
      expect(registers.getGPR(2), currentPC + 4);
    });
  });

  group('LHUInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('LHU correctly loads an unsigned halfword', () {
      const int address = 0x100;
      const int halfwordValue =
          0xFFFE; // Largest unsigned 16-bit integer minus 1
      memory.storeHalfword(address, halfwordValue);
      var instruction = LHUInstruction(2, 1, 0); // LHU x2, 0(x1)
      registers.setGPR(1, address); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded halfword is correct and zero-extended
      expect(registers.getGPR(2), halfwordValue);
    });

    test('LHU correctly loads a halfword using an offset', () {
      const int baseAddress = 0x100;
      const int offset = 2;
      const int halfwordValue = 0x00FF; // 255 in decimal
      memory.storeHalfword(baseAddress + offset, halfwordValue);
      var instruction = LHUInstruction(2, 1, offset); // LHU x2, 2(x1)
      registers.setGPR(1, baseAddress); // Set x1 to the base address

      instruction.execute(registers, memory);

      // Check if the loaded halfword from the correct offset is correct and zero-extended
      expect(registers.getGPR(2), halfwordValue);
    });
  });

  group('SBInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SB correctly stores the least significant byte of a register', () {
      const int baseAddress = 0x100;
      const int offset = 0x4;
      const int valueToStore = 0xAB; // Arbitrary byte value to store
      registers.setGPR(1, baseAddress); // Set x1 to the base address
      registers.setGPR(
          2, valueToStore | 0xFFFFFF00); // Ensure that x2 has other bits set
      var sbInstruction = SBInstruction(1, 2, offset); // SB x2, 4(x1)

      sbInstruction.execute(registers, memory);

      // The memory at baseAddress + offset should now hold the value 0xAB
      expect(memory.loadByte(baseAddress + offset), valueToStore);
    });

    test('SB correctly handles negative byte values', () {
      const int baseAddress = 0x100;
      const int offset = 0x4;
      const int valueToStore =
          0x80; // Represents a negative value in two's complement
      registers.setGPR(1, baseAddress); // Set x1 to the base address
      registers.setGPR(2, valueToStore); // Set x2 to the negative value
      var sbInstruction = SBInstruction(1, 2, offset); // SB x2, 4(x1)

      sbInstruction.execute(registers, memory);

      // The memory at baseAddress + offset should now hold the negative value
      // The loadByte method should sign-extend this negative value
      expect(memory.loadByte(baseAddress + offset), -128);
    });
  });

  group('SHInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
    });

    test('SH correctly stores the least significant halfword of a register',
        () {
      const int baseAddress = 0x100;
      const int offset = 0x2;
      const int valueToStore = 0xABCD; // Arbitrary halfword value to store
      registers.setGPR(1, baseAddress); // Set x1 to the base address
      registers.setGPR(
          2, valueToStore | 0xFFFF0000); // Ensure that x2 has other bits set
      var shInstruction = SHInstruction(1, 2, offset); // SH x2, 2(x1)

      shInstruction.execute(registers, memory);

      // The memory at baseAddress + offset should now hold the value 0xABCD
      expect(memory.loadHalfword(baseAddress + offset), valueToStore);
    });

    test('SH correctly handles negative halfword values', () {
      const int baseAddress = 0x100;
      const int offset = 0x2;
      const int valueToStore =
          0x8000; // Represents a negative value in two's complement
      registers.setGPR(1, baseAddress); // Set x1 to the base address
      registers.setGPR(2, valueToStore); // Set x2 to the negative value
      var shInstruction = SHInstruction(1, 2, offset); // SH x2, 2(x1)

      shInstruction.execute(registers, memory);

      // The memory at baseAddress + offset should now hold the negative value
      // The loadHalfword method should sign-extend this negative value
      expect(memory.loadHalfword(baseAddress + offset), -32768);
    });
  });

  group('BLTInstruction Tests', () {
    late Registers registers;
    late Memory memory;

    setUp(() {
      registers = Registers();
      memory = Memory(size: 1024);
      // Assume the program counter starts at 0
      registers.setPC(0);
    });

    test('BLT branches if the first register is less than the second', () {
      registers.setGPR(1, 1); // x1 = 1
      registers.setGPR(2, 2); // x2 = 2
      var bltInstruction = BLTInstruction(1, 2, 4); // BLT x1, x2, 4

      bltInstruction.execute(registers, memory);

      // The program counter should have been updated by the offset
      expect(registers.getPC(), 4);
    });

    test(
        'BLT does not branch if the first register is not less than the second',
        () {
      registers.setGPR(1, 2); // x1 = 2
      registers.setGPR(2, 1); // x2 = 1
      var bltInstruction = BLTInstruction(1, 2, 4); // BLT x1, x2, 4

      bltInstruction.execute(registers, memory);

      // The program counter should not have been updated
      expect(registers.getPC(), 0);
    });

    test('BLT branches correctly with negative offset', () {
      registers.setGPR(1, 1); // x1 = 1
      registers.setGPR(2, 2); // x2 = 2
      var bltInstruction = BLTInstruction(1, 2, -4); // BLT x1, x2, -4
      // Set the program counter to a non-zero value
      registers.setPC(10);

      bltInstruction.execute(registers, memory);

      // The program counter should have been updated by the negative offset
      expect(registers.getPC(), 6);
    });

    test('BLT handles signed comparison correctly', () {
      registers.setGPR(1, -1); // x1 = -1 (signed)
      registers.setGPR(2, 0); // x2 = 0
      var bltInstruction = BLTInstruction(1, 2, 4); // BLT x1, x2, 4

      bltInstruction.execute(registers, memory);

      // x1 is less than x2 when interpreted as signed integers, so the branch should be taken
      expect(registers.getPC(), 4);
    });
  });
}
