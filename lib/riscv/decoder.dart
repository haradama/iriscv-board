import 'instructions.dart';

class Decoder {
  // 命令をデコードして対応するInstructionオブジェクトを返す
  Instruction? decode(int instructionData) {
    // ここでは単純なRタイプの命令のデコードを例として示します

    // オペコードの取得 (下位7ビット)
    int opcode = instructionData & 0x7F;

    switch (opcode) {
      case 0x33: // Rタイプの命令のオペコード
        // funct3, funct7, rs1, rs2, rdを取得
        int funct3 = (instructionData >> 12) & 0x7;
        int funct7 = (instructionData >> 25) & 0x7F;
        int rs1 = (instructionData >> 15) & 0x1F;
        int rs2 = (instructionData >> 20) & 0x1F;
        int rd = (instructionData >> 7) & 0x1F;

        // 具体的なRタイプの命令を判別して返す
        if (funct3 == 0 && funct7 == 0) {
          // ADD命令の場合
          return ADDInstruction(rd, rs1, rs2);
        }
        // 他のRタイプ命令も同様に追加できる
        break;

      // 他のオペコードに対するデコードもここに追加

      default:
        return null;
    }

    return null;
  }
}
