import 'instructions.dart';

class Opcodes {
  // R-Type opcodes
  static const int op = 0x33;

  // I-Type opcodes
  static const int jalr = 0x67;
  static const int load = 0x03;
  static const int opImm = 0x13;
  static const int fence = 0x0F; // for fence instructions
  static const int system = 0x73; // for ECALL and EBREAK

  // S-Type opcodes
  static const int store = 0x23;

  // B-Type opcodes
  static const int branch = 0x63;

  // U-Type opcodes
  static const int lui = 0x37;
  static const int auipc = 0x17;

  // J-Type opcodes
  static const int jal = 0x6F;
}

class Decoder {
  Instruction? decode(int instruction) {
    // Extract the lowest 7 bits
    int opcode = instruction & 0x7F;
    switch (opcode) {
      // R-Type
      case Opcodes.op:
        _decodeRType(instruction);
      // I-Type
      case Opcodes.load:
      case Opcodes.fence:
      case Opcodes.opImm:
      case Opcodes.jalr:
      case Opcodes.system:
        _decodeIType(instruction);
      // S-Type
      case Opcodes.store:
        _decodeSType(instruction);
      // B-Type
      case Opcodes.branch:
        _decodeBType(instruction);
      // U-Type
      case Opcodes.lui:
      case Opcodes.auipc:
        _decodeUType(instruction);
      // J-Type
      case Opcodes.jal:
        _decodeJType(instruction);
      default:
        return null;
    }
    return null;
  }

  Instruction? _decodeRType(int instruction) {
    // | Field Name  | Bits Position | Width (bits) | Description                      |
    // |-------------|---------------|--------------|----------------------------------|
    // | `funct7`    | 31-25         | 7            | Function code (extends opcode)   |
    // | `rs2`       | 24-20         | 5            | Source register 2                |
    // | `rs1`       | 19-15         | 5            | Source register 1                |
    // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
    // | `rd`        | 11-7          | 5            | Destination register             |
    // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

    // Assuming the opcode has already been determined to be R-Type
    int rd = (instruction >> 7) & 0x1F;
    int funct3 = (instruction >> 12) & 0x7;
    int rs1 = (instruction >> 15) & 0x1F;
    int rs2 = (instruction >> 20) & 0x1F;
    int funct7 = (instruction >> 25) & 0x7F;

    switch (funct3) {
      case 0x0: // funct3 for ADD and SUB
        if (funct7 == 0x00) {
          return ADDInstruction(rd, rs1, rs2);
        } else if (funct7 == 0x20) {
          return SUBInstruction(rd, rs1, rs2);
        }
        break;
      case 0x1: // funct3 for SLL
        return SLLInstruction(rd, rs1, rs2);
      case 0x2: // funct3 for SLT
        return SLTInstruction(rd, rs1, rs2);
      case 0x3: // funct3 for SLTU
        return SLTUInstruction(rd, rs1, rs2);
      case 0x4: // funct3 for XOR
        return XORInstruction(rd, rs1, rs2);
      case 0x5: // funct3 for SRL and SRA
        if (funct7 == 0x00) {
          return SRLInstruction(rd, rs1, rs2);
        } else if (funct7 == 0x20) {
          return SRAInstruction(rd, rs1, rs2);
        }
        break;
      case 0x6: // funct3 for OR
        return ORInstruction(rd, rs1, rs2);
      case 0x7: // funct3 for AND
        return ANDInstruction(rd, rs1, rs2);
      default:
        return null; // Unknown or unsupported funct3 value
    }
    return null; // In case no match was found
  }

  Instruction? _decodeIType(int instruction) {
    // | Field Name  | Bits Position | Width (bits) | Description                      |
    // |-------------|---------------|--------------|----------------------------------|
    // | `imm`       | 31-20         | 12           | Immediate value                  |
    // | `rs1`       | 19-15         | 5            | Source register 1                |
    // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
    // | `rd`        | 11-7          | 5            | Destination register             |
    // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

    int rd = (instruction >> 7) & 0x1F;
    int funct3 = (instruction >> 12) & 0x7;
    int rs1 = (instruction >> 15) & 0x1F;
    // Immediate value is the top 12 bits of the instruction
    int imm = instruction >> 20;

    // Sign-extend the immediate if necessary (assuming a 32-bit system)
    imm = (imm << 20) >> 20;

    switch (funct3) {
      case 0x0: // funct3 for ADDI
        return ADDIInstruction(rd, rs1, imm);
      case 0x2: // funct3 for SLTI
        return SLTIInstruction(rd, rs1, imm);
      case 0x3: // funct3 for SLTIU
        return SLTIUInstruction(rd, rs1, imm);
      case 0x4: // funct3 for XORI
        return XORIInstruction(rd, rs1, imm);
      case 0x6: // funct3 for ORI
        return ORIInstruction(rd, rs1, imm);
      case 0x7: // funct3 for ANDI
        return ANDIInstruction(rd, rs1, imm);
      case 0x1: // funct3 for SLLI
        int shamt = imm & 0x1F;
        return SLLIInstruction(rd, rs1, shamt);
      case 0x5:
        int shamt = imm & 0x1F;
        if ((imm & 0x400) == 0) {
          return SRLIInstruction(rd, rs1, shamt);
        } else {
          return SRAIInstruction(rd, rs1, shamt);
        }
      // ... handle other funct3 values and instructions
      default:
        return null; // Unknown or unsupported funct3 value
    }
  }

  Instruction? _decodeSType(int instruction) {
    // | Field Name  | Bits Position | Width (bits) | Description                      |
    // |-------------|---------------|--------------|----------------------------------|
    // | `imm[11:5]` | 31-25         | 7            | Immediate value (most significant bits) |
    // | `rs2`       | 24-20         | 5            | Source register 2                |
    // | `rs1`       | 19-15         | 5            | Source register 1                |
    // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
    // | `imm[4:0]`  | 11-7          | 5            | Immediate value (least significant bits) |
    // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

    int imm5 = (instruction >> 7) & 0x1F;
    int funct3 = (instruction >> 12) & 0x7;
    int rs1 = (instruction >> 15) & 0x1F;
    int rs2 = (instruction >> 20) & 0x1F;
    int imm7 = (instruction >> 25) & 0x7F;

    // Combine the two parts of the immediate value
    int imm = (imm7 << 5) | imm5;
    // Sign-extend the immediate value if necessary (assuming a 32-bit system)
    imm = (imm << 20) >> 20;

    switch (funct3) {
      case 0x0: // funct3 for SB
        return SBInstruction(rs1, rs2, imm);
      case 0x1: // funct3 for SH
        return SHInstruction(rs1, rs2, imm);
      case 0x2: // funct3 for SW
        return SWInstruction(rs1, rs2, imm);
      // Add cases for additional S-type instructions if your RISC-V variant supports them
      default:
        return null; // Unknown or unsupported funct3 value
    }
  }

  Instruction? _decodeBType(int instruction) {
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

    // Extracting the various immediate segments from the instruction
    int imm11 = (instruction >> 7) & 0x1; // bit 11 of immediate
    int imm4_1 = (instruction >> 8) & 0xF; // bits 4:1 of immediate
    int imm10_5 = (instruction >> 25) & 0x3F; // bits 10:5 of immediate
    int imm12 = (instruction >> 31) & 0x1; // bit 12 of immediate

    // Reconstructing the full immediate from the segments
    int imm = (imm11 << 11) | (imm4_1 << 1) | (imm10_5 << 5) | (imm12 << 12);
    // Sign-extension of the immediate value
    imm = (imm << 19) >> 19;

    int funct3 = (instruction >> 12) & 0x7;
    int rs1 = (instruction >> 15) & 0x1F;
    int rs2 = (instruction >> 20) & 0x1F;

    switch (funct3) {
      case 0x0: // funct3 for BEQ
        return BEQInstruction(rs1, rs2, imm);
      case 0x1: // funct3 for BNE
        return BNEInstruction(rs1, rs2, imm);
      case 0x4: // funct3 for BLT
        return BLTInstruction(rs1, rs2, imm);
      case 0x5: // funct3 for BGE
        return BGEInstruction(rs1, rs2, imm);
      case 0x6: // funct3 for BLTU
        return BLTUInstruction(rs1, rs2, imm);
      case 0x7: // funct3 for BGEU
        return BGEUInstruction(rs1, rs2, imm);
      default:
        return null; // Unknown or unsupported funct3 value
    }
  }

  Instruction? _decodeUType(int instruction) {
    // | Field Name  | Bits Position | Width (bits) | Description                      |
    // |-------------|---------------|--------------|----------------------------------|
    // | `imm`       | 31-12         | 20           | Immediate value                  |
    // | `rd`        | 11-7          | 5            | Destination register             |
    // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |

    int opcode = instruction & 0x7F;
    int rd = (instruction >> 7) & 0x1F;
    // The immediate value for U-type instructions occupies bits 12 through 31
    int imm = instruction & 0xFFFFF000;

    switch (opcode) {
      case Opcodes.lui:
        return LUIInstruction(rd, imm);
      case Opcodes.auipc:
        return AUIPCInstruction(rd, imm);
      default:
        return null; // Unknown or unsupported opcode
    }
  }

  Instruction? _decodeJType(int instruction) {
    int rd = (instruction >> 7) & 0x1F;
    // Extracting the immediate value bits and putting them in the correct order
    int imm20 = (instruction >> 31) & 0x1; // 20th bit
    int imm10_1 = (instruction >> 21) & 0x3FF; // 10:1 bits
    int imm11 = (instruction >> 20) & 0x1; // 11th bit
    int imm19_12 = (instruction >> 12) & 0xFF; // 19:12 bits

    // Reconstructing the full immediate from the segments
    int imm = (imm20 << 20) | (imm19_12 << 12) | (imm11 << 11) | (imm10_1 << 1);
    // Sign-extension of the immediate value
    imm = (imm << 11) >> 11;

    return JALInstruction(rd, imm);
  }
}
