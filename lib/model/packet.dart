///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:59
///
part of 'models.dart';

/// 业务包实体
///
/// [status] 状态码, [command] 命令,
/// [sequence] 包序, [length] 包体长度, [content] 内容,
class Packet {
  const Packet({
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

  Packet combinedWith(Packet packet) {
    return Packet(
      status: packet.status,
      command: packet.command,
      sequence: packet.sequence,
      length: length + packet.length,
      content: <int>[...content, ...packet.content],
    );
  }

  final int status;
  final int command;
  final int sequence;
  final int length;
  final List<int> content;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'command': '0x${command.toRadixString(16)}',
      'sequence': sequence,
      'length': length,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Packet ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
