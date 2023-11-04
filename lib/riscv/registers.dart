import 'dart:typed_data';

class Registers {
  static const int numGPR = 32;
  static const int numCSR = 4096;

  static const int maxInt32 = (1 << 31) - 1;
  static const int minInt32 = -1 << 31;

  late Int32List _gprs;
  late Int32List _csrs;
  late int pc;

  Registers() {
    _gprs = Int32List(numGPR);
    _csrs = Int32List(numCSR);
    pc = 0;
  }

  int getGPR(int index) {
    assert(index >= 0 && index < numGPR,
        'GPR index must be between 0 and ${numGPR - 1}');
    int value = _gprs[index];
    return value;
  }

  void setGPR(int index, int value) {
    assert(index >= 0 && index < numGPR,
        'GPR index must be between 0 and ${numGPR - 1}');
    assert(value >= minInt32 && value <= maxInt32,
        'GPR value must be a valid 32-bit signed integer');

    if (index != 0) {
      _gprs[index] = value;
    }
  }

  void reset() {
    for (int i = 0; i < numGPR; i++) {
      _gprs[i] = 0;
    }
    pc = 0;
  }

  int getPC() {
    return pc;
  }

  void setPC(int value) {
    assert(value >= 0, 'PC value must be non-negative');
    pc = value;
  }

  void incrementPC() {
    assert(pc + 4 >= 0, 'PC value must be non-negative after increment');
    pc += 4;
  }

  int getCSR(int index) {
    assert(index >= 0 && index < numCSR,
        'CSR index must be between 0 and ${numCSR - 1}');
    return _csrs[index];
  }

  void setCSR(int index, int value) {
    assert(index >= 0 && index < numCSR,
        'CSR index must be between 0 and ${numCSR - 1}');
    _csrs[index] = value;
  }
}
