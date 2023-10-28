class Memory {
  late List<int> _data;
  final int size;

  Memory({required this.size}) {
    _data = List.filled(size, 0);
  }

  int fetch(int address) {
    if (address < 0 || address + 3 >= size) {
      throw Exception('Memory access out of bounds at address $address');
    }

    int value = 0;
    for (int i = 0; i < 4; i++) {
      value |= (_data[address + i] << (i * 8));
    }
    return value;
  }

  void store(int address, int value) {
    if (address < 0 || address + 3 >= size) {
      throw Exception('Memory access out of bounds at address $address');
    }

    for (int i = 0; i < 4; i++) {
      _data[address + i] = (value >> (i * 8)) & 0xFF;
    }
  }

  void reset() {
    for (int i = 0; i < size; i++) {
      _data[i] = 0;
    }
  }
}
