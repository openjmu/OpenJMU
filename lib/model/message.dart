///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 12:00
///
part of 'models.dart';

/// 消息实体
///
/// [type] 消息类型 ([Messages.PRPL_91U_MSG_TYPE])
/// [senderUid] 发送方uid
/// [senderMultiPortId] 发送方多点ID
/// [sendTime] 发送时间
/// [ackId] ACK ID
/// [content] 内容
@HiveType(typeId: HiveAdapterTypeIds.message)
class Message with HiveObject {
  Message({
    this.type,
    this.senderUid,
    this.senderMultiPortId,
    this.sendTime,
    this.ackId,
    this.content,
    this.read = false,
  });

  factory Message.fromEvent(MessageReceivedEvent event) {
    return Message(
      type: event.type,
      senderUid: event.senderUid.toInt(),
      senderMultiPortId: event.senderMultiPortId,
      sendTime: event.sendTime,
      ackId: event.ackId,
      content: event.content,
    );
  }

  @HiveField(0)
  int type;
  @HiveField(1)
  int senderUid;
  @HiveField(2)
  String senderMultiPortId;
  @HiveField(3)
  DateTime sendTime;
  @HiveField(4)
  int ackId;
  @HiveField(5)
  Map<String, dynamic> content;
  @HiveField(6)
  bool read;

  bool get isSelf => senderUid.toString() == currentUser.uid;
}
