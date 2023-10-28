import 'memory.dart';
import 'registers.dart';
import 'decoder.dart';
import 'instructions.dart';

class CPU {
  final Memory memory;
  final Registers registers;
  final Decoder decoder;

  CPU({required this.memory, required this.registers, required this.decoder});

  void reset() {
    registers.reset();
  }

  void step() {
    int instructionData = memory.fetch(registers.pc);
    Instruction? instruction = decoder.decode(instructionData);

    if (instruction != null) {
      instruction.execute(registers, memory);

      registers.incrementPC();
    } else {
      throw Exception('Invalid instruction at address ${registers.pc}');
    }
  }

  void run() {
    while (true) {
      step();
    }
  }
}