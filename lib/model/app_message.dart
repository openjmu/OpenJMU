///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 12:29
///
part of 'beans.dart';

/// 应用消息实体
///
/// [appId] 应用id, [permissionCode] 权限code, [messageId] 消息id,
/// [messageType] 消息类型, [sendTime] 发送时间, [read] 是否已读,
@HiveType(typeId: HiveAdapterTypeIds.appMessage)
class AppMessage with HiveObject {
  @HiveField(0)
  int appId;
  @HiveField(1)
  String permissionCode;
  @HiveField(2)
  int messageId;
  @HiveField(3)
  int messageType;
  @HiveField(4)
  DateTime sendTime;
  @HiveField(5)
  int ackId;
  @HiveField(6)
  String content;
  @HiveField(7)
  bool read;

  AppMessage({
    this.appId,
    this.permissionCode,
    this.messageId,
    this.messageType,
    this.sendTime,
    this.ackId,
    this.content,
    this.read = false,
  });

  factory AppMessage.fromEvent(MessageReceivedEvent event) {
    String content = event.content['content'] as String;
    content = content
        .replaceAll(String.fromCharCode(8), '\\n')
        .replaceAll(String.fromCharCode(10), '\\n')
        .replaceAll(String.fromCharCode(13), '\\n');
    for (int i = 0; i < content.length; i++) {
      if (content.codeUnitAt(i) < 32) {
        content = content.replaceRange(i, i + 1, '');
      }
    }
    final body = jsonDecode(content);
    return AppMessage(
      appId: body['appid'],
      permissionCode: body['permcode'],
      messageId: event.messageId,
      messageType: body['msgtype'],
      sendTime: event.sendTime,
      ackId: event.ackId,
      content: body['msgbody'],
    );
  }

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      appId: json['appId'],
      permissionCode: json['permissionCode'],
      messageId: json['messageId'],
      messageType: json['messageType'],
      sendTime: DateTime.parse(json['sendTime']),
      ackId: json['ackId'],
      content: json['content'],
      read: json['read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'permissionCode': permissionCode,
      'messageId': messageId,
      'messageType': messageType,
      'sendTime': sendTime.toString(),
      'ackId': ackId,
      'content': content,
      'read': read,
    };
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}
