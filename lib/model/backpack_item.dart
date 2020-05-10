///
/// [Author] Alex (https://github.com/AlexVincent525)
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

  final int id;
  final int type;
  final int count;
  final String name;
  final String description;

  factory BackpackItem.fromJson(Map<String, dynamic> json) {
    return BackpackItem(
      id: json['itemid'],
      type: json['itemtype'],
      count: json['pack_num'],
      name: json['name'],
      description: json['desc'],
    );
  }

  @override
  String toString() {
    return 'BackpackItem ${JsonEncoder.withIndent('' '').convert({
      'itemid': id,
      'itemtype': type,
      'pack_num': count,
      'name': name,
      'desc': description,
    })}';
  }
}

class BackpackItemType {
  const BackpackItemType({
    this.name,
    this.description,
    this.type,
    this.thankMessage,
  });

  final String name;
  final String description;
  final int type;
  final List<dynamic> thankMessage;

  factory BackpackItemType.fromJson(Map<String, dynamic> json) {
    return BackpackItemType(
      name: json['title'],
      description: json['desc'],
      type: json['itemtype'],
      thankMessage: json['thankmsg'],
    );
  }

  @override
  String toString() {
    return 'BackpackItemType ${JsonEncoder.withIndent('' '').convert({
      'title': name,
      'desc': description,
      'itemtype': type,
      'thankmsg': thankMessage,
    })}';
  }
}
