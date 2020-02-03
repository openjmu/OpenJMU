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

class ChangeLogAdapter extends TypeAdapter<ChangeLog> {
  @override
  final typeId = 5;

  @override
  ChangeLog read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChangeLog(
      version: fields[0] as String,
      buildNumber: fields[1] as int,
      date: fields[2] as String,
      sections: (fields[3] as Map)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChangeLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.buildNumber)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.sections);
  }
}

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final typeId = 2;

  @override
  Course read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      isCustom: fields[0] as bool,
      name: fields[1] as String,
      time: fields[2] as String,
      location: fields[3] as String,
      className: fields[4] as String,
      teacher: fields[5] as String,
      day: fields[6] as int,
      startWeek: fields[7] as int,
      endWeek: fields[8] as int,
      classesName: (fields[10] as List)?.cast<String>(),
      isEleven: fields[11] as bool,
      oddEven: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.isCustom)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.className)
      ..writeByte(5)
      ..write(obj.teacher)
      ..writeByte(6)
      ..write(obj.day)
      ..writeByte(7)
      ..write(obj.startWeek)
      ..writeByte(8)
      ..write(obj.endWeek)
      ..writeByte(9)
      ..write(obj.oddEven)
      ..writeByte(10)
      ..write(obj.classesName)
      ..writeByte(11)
      ..write(obj.isEleven);
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

class ScoreAdapter extends TypeAdapter<Score> {
  @override
  final typeId = 3;

  @override
  Score read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Score(
      code: fields[0] as String,
      courseName: fields[1] as String,
      score: fields[2] as String,
      termId: fields[3] as String,
      credit: fields[4] as double,
      creditHour: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Score obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.termId)
      ..writeByte(4)
      ..write(obj.credit)
      ..writeByte(5)
      ..write(obj.creditHour);
  }
}

class WebAppAdapter extends TypeAdapter<WebApp> {
  @override
  final typeId = 4;

  @override
  WebApp read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebApp(
      appId: fields[0] as int,
      sequence: fields[1] as int,
      code: fields[2] as String,
      name: fields[3] as String,
      url: fields[4] as String,
      menuType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WebApp obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.appId)
      ..writeByte(1)
      ..write(obj.sequence)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.menuType);
  }
}
