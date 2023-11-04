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

        switch (funct3) {
          case 0x0:
            if (funct7 == 0x00) {
              return ADDInstruction(rd, rs1, rs2); // ADD
            } else if (funct7 == 0x20) {
              return SUBInstruction(rd, rs1, rs2); // SUB
            }
            break;
          case 0x1:
            return SLLInstruction(rd, rs1, rs2); // SLL
          case 0x2:
            return SLTInstruction(rd, rs1, rs2); // SLT
          case 0x3:
            return SLTUInstruction(rd, rs1, rs2); // SLTU
          case 0x4:
            return XORInstruction(rd, rs1, rs2); // XOR
          case 0x5:
            if (funct7 == 0x00) {
              return SRLInstruction(rd, rs1, rs2); // SRL
            } else if (funct7 == 0x20) {
              return SRAInstruction(rd, rs1, rs2); // SRA
            }
            break;
          case 0x6:
            return ORInstruction(rd, rs1, rs2); // OR
          case 0x7:
            return ANDInstruction(rd, rs1, rs2); // AND
          default:
            return null; // Unknown funct3 for Opcodes.op
        }
        break;

      case Opcodes.lui: // U-type
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-12         | 20           | Immediate value                  |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        int rd = (instructionData >> 7) & 0x1F;
        int imm =
            (instructionData >> 12) & 0xFFFFF; // Extract 20-bit immediate value
        return LUIInstruction(rd, imm);

      case Opcodes.auipc: // U-type
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-12         | 20           | Immediate value                  |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        int rd = (instructionData >> 7) & 0x1F;
        int imm =
            (instructionData >> 12) & 0xFFFFF; // Extract 20-bit immediate value
        return AUIPCInstruction(rd, imm);

      case Opcodes.opImm:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-20         | 12           | Immediate value                  |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        int rd = (instructionData >> 7) & 0x1F;
        int rs1 = (instructionData >> 15) & 0x1F;
        int funct3 = (instructionData >> 12) & 0x7;
        int imm = (instructionData >> 20); // The sign-extended immediate value

        // Sign-extend the 12-bit immediate to 32 bits
        imm = (imm << 20) >> 20;

        // Decode based on funct3
        switch (funct3) {
          case 0x0: // ADDI
            return ADDIInstruction(rd, rs1, imm);
          case 0x2: // SLTI
            return SLTIInstruction(rd, rs1, imm);
          case 0x3: // SLTIU
            return SLTIUInstruction(rd, rs1, imm);
          case 0x4: // XORI
            return XORIInstruction(rd, rs1, imm);
          case 0x6: // ORI
            return ORIInstruction(rd, rs1, imm);
          case 0x7: // ANDI
            return ANDIInstruction(rd, rs1, imm);
          case 0x1: // SLLI
            int shamt = imm & 0x1F;
            return SLLIInstruction(rd, rs1, shamt);
          case 0x5:
            int shamt = imm & 0x1F;
            if ((imm & 0x400) == 0) {
              // SRLI
              return SRLIInstruction(rd, rs1, shamt);
            } else {
              // SRAI
              return SRAIInstruction(rd, rs1, shamt);
            }
          default:
            return null; // Unknown funct3 for opImm
        }

      case Opcodes.load:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm`       | 31-20         | 12           | Immediate value                  |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `rd`        | 11-7          | 5            | Destination register             |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        int rd = (instructionData >> 7) & 0x1F;
        int rs1 = (instructionData >> 15) & 0x1F;
        int funct3 = (instructionData >> 12) & 0x7;
        int imm = (instructionData >> 20); // The sign-extended immediate value

        // Sign-extend the 12-bit immediate to 32 bits
        imm = (imm << 20) >> 20;

        // Decode based on funct3
        switch (funct3) {
          case 0x0: // LB
            return LBInstruction(rd, rs1, imm);
          case 0x1: // LH
            return LHInstruction(rd, rs1, imm);
          case 0x2: // LW
            return LWInstruction(rd, rs1, imm);
          default:
            return null; // Unknown funct3 for load
        }

      case Opcodes.store:
        // | Field Name  | Bits Position | Width (bits) | Description                      |
        // |-------------|---------------|--------------|----------------------------------|
        // | `imm[11:5]` | 31-25         | 7            | Immediate value (most significant bits) |
        // | `rs2`       | 24-20         | 5            | Source register 2                |
        // | `rs1`       | 19-15         | 5            | Source register 1                |
        // | `funct3`    | 14-12         | 3            | Function code (extends opcode)   |
        // | `imm[4:0]`  | 11-7          | 5            | Immediate value (least significant bits) |
        // | `opcode`    | 6-0           | 7            | Operation code (specifies instr) |
        int imm5 =
            (instructionData >> 7) & 0x1F; // bits [11:7] of the immediate
        int rs1 = (instructionData >> 15) & 0x1F;
        int rs2 = (instructionData >> 20) & 0x1F;
        int funct3 = (instructionData >> 12) & 0x7;
        int imm7 =
            (instructionData >> 25) & 0x7F; // bits [31:25] of the immediate
        int imm = (imm7 << 5) |
            imm5; // Combine imm7 and imm5 to form the 12-bit immediate

        // Sign-extend the 12-bit immediate to 32 bits
        imm = (imm << 20) >> 20;

        // Decode based on funct3
        switch (funct3) {
          case 0x0: // SB
            return SBInstruction(rs1, rs2, imm);
          case 0x1: // SH
            return SHInstruction(rs1, rs2, imm);
          case 0x2: // SW
            return SWInstruction(rs1, rs2, imm);
          // Add cases for other funct3 values for different store sizes
          // ...
          default:
            return null; // Unknown funct3 for store
        }

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
        int imm11 = (instructionData >> 7) & 0x1; // bit [11] of the immediate
        int imm4_1 =
            (instructionData >> 8) & 0xF; // bits [4:1] of the immediate
        int imm10_5 =
            (instructionData >> 25) & 0x3F; // bits [10:5] of the immediate
        int imm12 = (instructionData >> 31) & 0x1; // bit [12] of the immediate
        int rs1 = (instructionData >> 15) & 0x1F;
        int rs2 = (instructionData >> 20) & 0x1F;
        int funct3 = (instructionData >> 12) & 0x7;
        // Construct the 13-bit immediate (sign-extend, shift, and combine the parts)
        int imm =
            ((imm12 << 12) | (imm11 << 11) | (imm10_5 << 5) | (imm4_1 << 1));
        // Sign-extend the 13-bit immediate to 32 bits
        imm = (imm << 19) >> 19;

        // Decode based on funct3
        switch (funct3) {
          case 0x0: // BEQ
            return BEQInstruction(rs1, rs2, imm);
          case 0x1: // BNE
            return BNEInstruction(rs1, rs2, imm);
          // Add cases for other funct3 values for BLT, BGE, BLTU, BGEU
          // ...
          default:
            return null; // Unknown funct3 for branch
        }

      default:
        return null;
    }

    return null;
  }
}
