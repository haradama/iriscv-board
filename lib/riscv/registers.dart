class Registers {
  static const int numGeneralPurposeRegisters = 32; // x0-x31

  // 汎用レジスタ
  late List<int> _gprs;

  // プログラムカウンター
  late int pc;

  Registers() {
    _gprs = List.filled(numGeneralPurposeRegisters, 0);
    pc = 0;
  }

  // 指定された汎用レジスタから値を取得
  int getGPR(int index) {
    _validateGPRIndex(index);
    return _gprs[index];
  }

  // 指定された汎用レジスタに値を設定
  void setGPR(int index, int value) {
    _validateGPRIndex(index);
    if (index != 0) {
      // x0 (zero) レジスタは常に0
      _gprs[index] = value;
    }
  }

  // レジスタセットのリセット
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

  // 汎用レジスタのインデックスのバリデーション
  void _validateGPRIndex(int index) {
    if (index < 0 || index >= numGeneralPurposeRegisters) {
      throw Exception('Invalid GPR index: $index');
    }
  }
}
