import 'dart:typed_data';

class Memory {
  late Uint8List _data;
  final int size;

  Memory({required this.size}) {
    _data = Uint8List.fromList(List.filled(size, 0));
  }

  int fetch(int address) {
    if (address < 0 || address >= size) {
      throw Exception('Memory access out of bounds at address $address');
    }
    // The result needs to be returned as a signed integer to handle negative values correctly.
    // This is done by sign-extending the byte.
    int byteValue = _data[address];
    // Perform sign extension
    return byteValue.toSigned(8);
  }

  void store(int address, int value) {
    if (address < 0 || address + 3 >= size) {
      throw Exception('Memory access out of bounds at address $address');
    }

    _data[address] = value & 0xFF;
    _data[address + 1] = (value >> 8) & 0xFF;
    _data[address + 2] = (value >> 16) & 0xFF;
    _data[address + 3] = (value >> 24) & 0xFF;
  }

  void reset() {
    for (int i = 0; i < size; i++) {
      _data[i] = 0;
    }
  }
}
