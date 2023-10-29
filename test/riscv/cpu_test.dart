import 'package:flutter_test/flutter_test.dart';
import 'package:iriscv_board/riscv/instructions.dart';
import 'package:iriscv_board/riscv/memory.dart';
import 'package:iriscv_board/riscv/registers.dart';
import 'package:iriscv_board/riscv/decoder.dart';
import 'package:iriscv_board/riscv/cpu.dart';

// Mock instruction to use in testing
class MockInstruction extends Instruction {
  final void Function() onExecute;
  MockInstruction(this.onExecute) : super([]);

  @override
  void execute(Registers registers, Memory memory) {
    onExecute();
  }

  @override
  String toString() => 'MockInstruction';
}

// Mock Decoder
class MockDecoder extends Decoder {
  Function(int)? customDecode;

  MockDecoder({this.customDecode});

  @override
  Instruction? decode(int instructionData) {
    if (customDecode != null) {
      return customDecode!(instructionData);
    }
    return super.decode(instructionData);
  }
}

void main() {
  group('CPU Tests', () {
    late CPU cpu;
    late Memory memory;
    late Registers registers;
    late MockDecoder mockDecoder;

    setUp(() {
      memory = Memory(size: 1024);
      registers = Registers();
      mockDecoder = MockDecoder();

      cpu = CPU(memory: memory, registers: registers, decoder: mockDecoder);
    });

    test('CPU reset sets registers to initial state', () {
      registers.setGPR(1, 123);
      cpu.reset();
      expect(registers.getGPR(1), equals(0));
    });

    test('CPU step executes a single instruction', () {
      bool executed = false;
      mockDecoder.customDecode = (int instructionData) => MockInstruction(() {
            executed = true;
          });

      memory.store(0, 0x12345678);
      cpu.step();

      expect(executed, isTrue);
      expect(registers.getPC(), equals(4));
    });

    test('CPU throws exception on invalid instruction', () {
      mockDecoder.customDecode = (int instructionData) => null;

      expect(() => cpu.step(), throwsA(isA<Exception>()));
    });
  });
}
