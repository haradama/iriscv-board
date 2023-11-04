import 'dart:typed_data';

import 'package:iriscv_board/riscv/memory.dart';
import 'package:iriscv_board/riscv/registers.dart';
import 'package:iriscv_board/riscv/decoder.dart';
import 'package:iriscv_board/riscv/cpu.dart';

class Emulator {
  late Memory memory;
  late Registers registers;
  late Decoder decoder;
  late CPU cpu;
  final int memorySize;

  Emulator({required this.memorySize}) {
    memory = Memory(size: memorySize);
    registers = Registers();
    decoder = Decoder();
    cpu = CPU(memory: memory, registers: registers, decoder: decoder);
  }

  void load(Uint8List programData) {
    for (int i = 0; i < programData.length; i++) {
      memory.store(i, programData[i]);
    }
  }

  void run() {
    cpu.run();
  }
}
