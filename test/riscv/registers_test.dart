import 'package:flutter_test/flutter_test.dart';
import 'package:iriscv_board/riscv/registers.dart';

void main() {
  group('Registers Tests', () {
    late Registers registers;

    setUp(() {
      // Initialize Registers before each test
      registers = Registers();
    });

    test('General purpose registers are initialized to zero', () {
      for (int i = 0; i < Registers.numGPR; i++) {
        expect(registers.getGPR(i), equals(0));
      }
    });

    test('Program counter is initialized to zero', () {
      expect(registers.getPC(), equals(0));
    });

    test('Setting and getting GPR values', () {
      registers.setGPR(1, 42);
      expect(registers.getGPR(1), equals(42));
    });

    test('Reset sets all GPRs and PC to zero', () {
      registers.setGPR(1, 42);
      registers.setPC(100);
      registers.reset();
      expect(registers.getGPR(1), equals(0));
      expect(registers.getPC(), equals(0));
    });

    test('Incrementing PC', () {
      registers.setPC(100);
      registers.incrementPC();
      expect(registers.getPC(), equals(104));
    });

    test('Setting and getting CSR values', () {
      registers.setCSR(100, 42);
      expect(registers.getCSR(100), equals(42));
    });
  });
}
