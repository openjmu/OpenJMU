///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 12:29
///
part of 'models.dart';

/// 应用消息实体
///
/// [appId] 应用id, [permissionCode] 权限code, [messageId] 消息id,
/// [messageType] 消息类型, [sendTime] 发送时间, [read] 是否已读,
@HiveType(typeId: HiveAdapterTypeIds.appMessage)
class AppMessage with HiveObject {
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
    final Map<String, dynamic> body =
        jsonDecode(content) as Map<String, dynamic>;
    return AppMessage(
      appId: body['appid'] as int,
      permissionCode: body['permcode']?.toString(),
      messageId: event.messageId,
      messageType: body['msgtype'] as int,
      sendTime: event.sendTime,
      ackId: event.ackId,
      content: body['msgbody']?.toString(),
    );
  }

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      appId: json['appId'] as int,
      permissionCode: json['permissionCode']?.toString(),
      messageId: json['messageId'] as int,
      messageType: json['messageType'] as int,
      sendTime: DateTime.parse(json['sendTime']?.toString()),
      ackId: json['ackId'] as int,
      content: json['content']?.toString(),
      read: json['read'] as bool,
    );
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
