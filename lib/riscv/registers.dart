class Registers {
  static const int numGeneralPurposeRegisters = 32;
  static const int numCSR = 4096;

  late List<int> _gprs;
  late List<int> _csrs;
  late int pc;

  Registers() {
    _gprs = List.filled(numGeneralPurposeRegisters, 0);
    _csrs = List.filled(numCSR, 0);
    pc = 0;
  }

  int getGPR(int index) {
    _validateGPRIndex(index);
    return _gprs[index];
  }

  void setGPR(int index, int value) {
    _validateGPRIndex(index);
    if (index != 0) {
      _gprs[index] = value;
    }
  }

  void reset() {
    for (int i = 0; i < numGeneralPurposeRegisters; i++) {
      _gprs[i] = 0;
    }
    pc = 0;
  }

  int getPC() {
    return pc;
  }

  void setPC(int value) {
    pc = value;
  }

  void incrementPC() {
    pc += 4;
  }

  void _validateGPRIndex(int index) {
    if (index < 0 || index >= numGeneralPurposeRegisters) {
      throw Exception('Invalid GPR index: $index');
    }
  }

  int getCSR(int index) {
    _validateCSRIndex(index);
    return _csrs[index];
  }

  void setCSR(int index, int value) {
    _validateCSRIndex(index);
    _csrs[index] = value;
  }

  void _validateCSRIndex(int index) {
    if (index < 0 || index >= numCSR) {
      throw Exception('Invalid CSR index: $index');
    }
  }
}
