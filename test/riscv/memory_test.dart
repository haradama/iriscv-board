import 'package:flutter_test/flutter_test.dart';
import 'package:iriscv_board/riscv/memory.dart';

void main() {
  group('Memory Tests', () {
    // Size of memory for testing
    const int testMemorySize = 1024; // 1KB of memory
    late Memory memory;

    setUp(() {
      // Initialize memory before each test
      memory = Memory(size: testMemorySize);
    });

    test('Memory is initialized with the correct size', () {
      expect(memory.size, equals(testMemorySize));
    });

    test('Store and fetch a word from memory', () {
      int address = 100;
      int value = 0x12345678;
      memory.store(address, value);
      int fetchedValue = memory.fetch(address);
      expect(fetchedValue, equals(value));
    });

    test('Reset sets all memory values to zero', () {
      int address = 100;
      int value = 0x12345678;
      memory.store(address, value);

      memory.reset();
      int fetchedValue = memory.fetch(address);
      expect(fetchedValue, equals(0));
    });

    test('Fetching from an out-of-bounds address throws an exception', () {
      int address = testMemorySize; // Out of bounds
      expect(() => memory.fetch(address), throwsA(isA<Exception>()));
    });

    test('Storing to an out-of-bounds address throws an exception', () {
      int address = testMemorySize; // Out of bounds
      int value = 0x12345678;
      expect(() => memory.store(address, value), throwsA(isA<Exception>()));
    });

    test('Storing and fetching negative values retains sign', () {
      int address = 100;
      int value = -1; // 0xFFFFFFFF in two's complement
      memory.store(address, value);
      int fetchedValue = memory.fetch(address);
      expect(fetchedValue, equals(0xFFFFFFFF));
    });
  });
}
