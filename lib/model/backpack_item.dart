///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/3/31 13:05
///
part of 'models.dart';

class BackpackItem {
  const BackpackItem({
    this.id,
    this.type,
    this.count,
    this.name,
    this.description,
  });

  factory BackpackItem.fromJson(Map<String, dynamic> json) {
    return BackpackItem(
      id: json['itemid'] as int,
      type: json['itemtype'] as int,
      count: json['pack_num'] as int,
      name: json['name']?.toString(),
      description: json['desc']?.toString(),
    );
  }

  final int id;
  final int type;
  final int count;
  final String name;
  final String description;

  BackpackItemSpecialType get specialType {
    if (type == 10000) {
      return BackpackItemSpecialType.lotteryTicket;
    } else if (type == 20000) {
      return BackpackItemSpecialType.flower;
    } else {
      return BackpackItemSpecialType.common;
    }
  }

  @override
  String toString() {
    return 'BackpackItem ${const JsonEncoder.withIndent('' '').convert(
      <String, dynamic>{
        'itemid': id,
        'itemtype': type,
        'pack_num': count,
        'name': name,
        'desc': description,
      },
    )}';
  }
}

class BackpackItemType {
  const BackpackItemType({
    this.name,
    this.description,
    this.type,
    this.thankMessage,
  });

  factory BackpackItemType.fromJson(Map<String, dynamic> json) {
    return BackpackItemType(
      name: json['title']?.toString(),
      description: json['desc']?.toString(),
      type: json['itemtype'] as int,
      thankMessage: json['thankmsg'] as List<dynamic>,
    );
  }

  final String name;
  final String description;
  final int type;
  final List<dynamic> thankMessage;

  @override
  String toString() {
    return 'BackpackItemType ${const JsonEncoder.withIndent('' '').convert(
      <String, dynamic>{
        'title': name,
        'desc': description,
        'itemtype': type,
        'thankmsg': thankMessage,
      },
    )}';
  }
}

enum BackpackItemSpecialType {
  lotteryTicket,
  flower,
  common,
}
