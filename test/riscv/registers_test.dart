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
      for (int i = 0; i < Registers.numGeneralPurposeRegisters; i++) {
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

    test('Accessing GPR with invalid index throws exception', () {
      expect(() => registers.getGPR(32), throwsA(isA<Exception>()));
      expect(() => registers.setGPR(32, 42), throwsA(isA<Exception>()));
    });

    test('Setting and getting CSR values', () {
      registers.setCSR(100, 42);
      expect(registers.getCSR(100), equals(42));
    });

    test('Accessing CSR with invalid index throws exception', () {
      expect(() => registers.getCSR(4096), throwsA(isA<Exception>()));
      expect(() => registers.setCSR(4096, 42), throwsA(isA<Exception>()));
    });
  });
}
