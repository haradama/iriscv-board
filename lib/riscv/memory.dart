import 'dart:typed_data';

class Memory {
  late Uint8List _data;
  final int size;

  static const int maxInt32 = (1 << 31) - 1;
  static const int minInt32 = -1 << 31;

  static const int maxInt16 = (1 << 15) - 1;
  static const int minInt16 = -1 << 15;

  static const int maxInt8 = (1 << 7) - 1;
  static const int minInt8 = -1 << 7;

  Memory({required this.size}) {
    _data = Uint8List(size);
  }

  int fetch(int address) {
    assert(address >= 0 && address + 3 < size,
        'Memory access out of bounds at address $address');

    // Construct the word from the 4 bytes in little-endian order
    int value = _data[address] |
        (_data[address + 1] << 8) |
        (_data[address + 2] << 16) |
        (_data[address + 3] << 24);
    return value.toSigned(32);
  }

  void store(int address, int value) {
    assert(address >= 0 && address + 3 < size,
        'Memory access out of bounds at address $address');
    assert(value >= minInt32 && value <= maxInt32,
        'GPR value must be a valid 32-bit signed integer');

    _data[address] = value & 0xFF;
    _data[address + 1] = (value >> 8) & 0xFF;
    _data[address + 2] = (value >> 16) & 0xFF;
    _data[address + 3] = (value >> 24) & 0xFF;
  }

  int loadByte(int address) {
    assert(address >= 0 && address < size,
        'Memory access out of bounds at address $address');

    int value = _data[address];
    return value.toSigned(8);
  }

  int loadUnsignedByte(int address) {
    assert(address >= 0 && address < size,
        'Memory access out of bounds at address $address');

    // Load the byte and zero-extend it to 32 bits
    int value = _data[address];
    return value.toUnsigned(8);
  }

  void storeByte(int address, int value) {
    assert(address >= 0 && address < size,
        'Memory access out of bounds at address $address');
    assert(value >= minInt8 && value <= maxInt8,
        'Value must be a valid 8-bit signed integer');

    _data[address] = value;
  }

  int loadHalfword(int address) {
    assert(address >= 0 && address + 1 < size,
        'Memory access out of bounds at address $address');

    // Construct the halfword from the 2 bytes in little-endian order
    int value = _data[address] | (_data[address + 1] << 8);
    // Sign-extend the 16-bit value to 32 bits
    return value.toSigned(16);
  }

  int loadUnsignedHalfword(int address) {
    assert(address >= 0 && address + 1 < size,
        'Memory access out of bounds at address $address');

    // Construct the unsigned halfword from the 2 bytes in little-endian order
    int value = _data[address] | (_data[address + 1] << 8);
    // Zero-extend the 16-bit value to 32 bits
    return value.toUnsigned(16);
  }

  void storeHalfword(int address, int value) {
    assert(address >= 0 && address + 1 < size,
        'Memory access out of bounds at address $address');
    assert(value >= minInt16 && value <= maxInt16,
        'Value must be a valid 16-bit signed integer');

    _data[address] = value & 0xFF;
    _data[address + 1] = (value >> 8) & 0xFF;
  }

  void reset() {
    for (int i = 0; i < size; i++) {
      _data[i] = 0;
    }
  }
}
