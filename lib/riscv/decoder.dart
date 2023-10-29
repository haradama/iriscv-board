import 'instructions.dart';

class Opcodes {
  // I-Type
  static const int lui = 0x37;
  static const int auipc = 0x17;
  static const int jal = 0x6F;
  static const int jalr = 0x67;
  static const int load = 0x03;
  static const int opImm = 0x13;
  static const int opImm32 = 0x1B; // For RV64I

  // R-Type
  static const int op = 0x33;

  // S-Type
  static const int store = 0x23;

  // B-Type
  static const int branch = 0x63;

  // System
  static const int system = 0x73;

  // Fence
  static const int fence = 0x0F;

  // AMO (For atomic instructions in the A extension)
  static const int amo = 0x2F;
}

class Decoder {
  Instruction? decode(int instructionData) {
    int opcode = instructionData & 0x7F;

    switch (opcode) {
      case Opcodes.op: // R-type instructions
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `funct7`    | 31-25         | 7            | Function code (extends opcode)   |
        // | `rs2`       | 24-20         | 5            | Source register 2                |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

        int funct7 = (instructionData >> 25) & 0x7F;
        int rs1 = (instructionData >> 15) & 0x1F;
        int rs2 = (instructionData >> 20) & 0x1F;
        int funct3 = (instructionData >> 12) & 0x7;
        int rd = (instructionData >> 7) & 0x1F;

        if (funct3 == 0 && funct7 == 0) {
          return ADDInstruction(rd, rs1, rs2);
        }
        break;

      case Opcodes.lui: // U-type
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-12         | 20           | Immediate value                  |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        break;

      case Opcodes.auipc: // U-type
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-12         | 20           | Immediate value                  |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

        break;

      case Opcodes.opImm:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-20         | 12           | Immediate value                  |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

        break;
      case Opcodes.load:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-20         | 12           | Immediate value                  |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

        break;
      case Opcodes.store:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm[11:5]` | 31-25         | 7            | Immediate value (most significant bits) |
        // | `rs2`       | 24-20         | 5            | Source register 2                |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `imm[4:0]`  | 11-7          | 5            | Immediate value (least significant bits) |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        break;

      case Opcodes.branch:
        // | Field Name   | Bits Position | Width (bits) | Description                      |
        // |--------------|---------------|--------------|----------------------------------|
        // | `imm[12]`    | 31            | 1            | Immediate value (sign bit)       |
        // | `imm[10:5]`  | 30-25         | 6            | Immediate value (part)           |
        // | `rs2`        | 24-20         | 5            | Source register 2                |
        // | `rs1`        | 19-15         | 5            | Source register 1                |
        // | `funct3`     | 14-12         | 3            | Function code (extends opcode)   |
        // | `imm[4:1]`   | 11-8          | 4            | Immediate value (part)           |
        // | `imm[11]`    | 7             | 1            | Immediate value (part)           |
        // | `opcode`     | 6-0           | 7            | Operation code (specifies instr) |
        break;

      default:
        return null;
    }

    return null;
  }
}
