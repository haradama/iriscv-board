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

    test('store and fetch a word', () {
      int address = 100;
      int value = -2147483648;
      memory.store(address, value);
      expect(memory.fetch(address), equals(value));
      value = 2147483647;
      memory.store(address, value);
      expect(memory.fetch(address), equals(value));
    });

    test('store and fetch a halfword', () {
      int address = 200;
      int value = -32768; // Min value for a signed 16-bit integer
      memory.storeHalfword(address, value);
      expect(memory.loadHalfword(address), equals(value));
      value = 32767; // Max value for a signed 16-bit integer
      memory.storeHalfword(address, value);
      expect(memory.loadHalfword(address), equals(value));
    });

    test('store and fetch a byte', () {
      int address = 300;
      int value = -128; // Min value for a signed 8-bit integer
      memory.storeByte(address, value);
      expect(memory.loadByte(address), equals(value));
      value = 127;
      memory.storeByte(address, value);
      expect(memory.loadByte(address), equals(value));
    });

    test('Reset sets all memory values to zero', () {
      int address = 100;
      int value = 0x12345678;
      memory.store(address, value);

      memory.reset();
      int fetchedValue = memory.fetch(address);
      expect(fetchedValue, equals(0));
    });

    test('Storing and fetching negative values retains sign', () {
      int address = 100;
      int value = -1;
      memory.store(address, value);
      int fetchedValue = memory.fetch(address);
      expect(fetchedValue, equals(-1));
    });
  });
}
