// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beans.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppMessageAdapter extends TypeAdapter<AppMessage> {
  @override
  final typeId = 0;

  @override
  AppMessage read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppMessage(
      appId: fields[0] as int,
      permissionCode: fields[1] as String,
      messageId: fields[2] as int,
      messageType: fields[3] as int,
      sendTime: fields[4] as DateTime,
      ackId: fields[5] as int,
      content: fields[6] as String,
      read: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.appId)
      ..writeByte(1)
      ..write(obj.permissionCode)
      ..writeByte(2)
      ..write(obj.messageId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.sendTime)
      ..writeByte(5)
      ..write(obj.ackId)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(7)
      ..write(obj.read);
  }
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final typeId = 1;

  @override
  Message read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      type: fields[0] as int,
      senderUid: fields[1] as int,
      senderMultiPortId: fields[2] as String,
      sendTime: fields[3] as DateTime,
      ackId: fields[4] as int,
      content: (fields[5] as Map)?.cast<String, dynamic>(),
      read: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.senderUid)
      ..writeByte(2)
      ..write(obj.senderMultiPortId)
      ..writeByte(3)
      ..write(obj.sendTime)
      ..writeByte(4)
      ..write(obj.ackId)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.read);
  }
}
