///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:59
///
part of 'beans.dart';

///
/// 业务包实体
/// [status] 状态码, [command] 命令,
/// [sequence] 包序, [length] 包体长度, [content] 内容,
///
class Packet {
  int status;
  int command;
  int sequence;
  int length;
  List<int> content;

  Packet({
    this.status,
    this.command,
    this.sequence,
    this.length,
    this.content,
  });

  factory Packet.fromBytes(List<int> bytes) {
    return Packet(
      status: MessageUtils.getPackageUint(bytes.sublist(4, 6), 16),
      command: MessageUtils.getPackageUint(bytes.sublist(18, 20), 16),
      sequence: MessageUtils.getPackageUint(bytes.sublist(20, 24), 32),
      length: MessageUtils.getPackageUint(bytes.sublist(24, 28), 32),
      content: bytes.sublist(28),
    );
  }

  @override
  String toString() {
    return 'Packet {\n'
        '  status: $status,\n'
        '  command: 0x${command.toRadixString(16)},\n'
        '  sequence: $sequence,\n'
        '  length: $length,\n'
        '  content: $content\n'
        '}';
  }
}
