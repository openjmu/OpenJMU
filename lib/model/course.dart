///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:55
///
part of 'beans.dart';

///
/// 课程
/// [isCustom] **必需**是否自定义课程,
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称,
/// [teacher] 教师名称, [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [classesName] 共同上课的班级,
/// [isEleven] 是否第十一节,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周
///
@HiveType(typeId: HiveAdapterTypeIds.course)
class Course {
  @HiveField(0)
  bool isCustom;
  @HiveField(1)
  String name;
  @HiveField(2)
  String time;
  @HiveField(3)
  String location;
  @HiveField(4)
  String className;
  @HiveField(5)
  String teacher;
  @HiveField(6)
  int day;
  @HiveField(7)
  int startWeek;
  @HiveField(8)
  int endWeek;
  @HiveField(9)
  int oddEven;
  @HiveField(10)
  List<String> classesName;
  @HiveField(11)
  bool isEleven;
  Color color;

  Course({
    @required this.isCustom,
    this.name,
    this.time,
    this.location,
    this.className,
    this.teacher,
    this.day,
    this.startWeek,
    this.endWeek,
    this.classesName,
    this.isEleven,
    this.oddEven,
  });

  static int judgeOddEven(Map<String, dynamic> json) {
    int _oddEven = 0;
    final _split = json['allWeek'].split(' ');
    if (_split.length > 1) {
      if (_split[1] == "单周") {
        _oddEven = 1;
      } else if (_split[1] == "双周") {
        _oddEven = 2;
      }
    }
    return _oddEven;
  }

  factory Course.fromJson(Map<String, dynamic> json, {bool isCustom = false}) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    final _oddEven = !isCustom ? judgeOddEven(json) : null;
    final weeks = !isCustom ? json['allWeek'].split(' ')[0].split('-') : null;

    String name;
    if (isCustom) {
      try {
        name = Uri.decodeComponent(json['content']);
      } catch (e) {
        name = json['content'];
      }
    } else {
      name = json['couName'] ?? "(空)";
    }

    Course _c = Course(
      isCustom: isCustom,
      name: name,
      time: !isCustom ? json['coudeTime'] : json['courseTime'].toString(),
      location: json['couRoom'],
      className: json['className'],
      teacher: json['couTeaName'],
      day: int.parse(
        (!isCustom ? json['couDayTime'] : json['courseDaytime']).toString().substring(0, 1),
      ),
      startWeek: !isCustom ? int.parse(weeks[0]) : null,
      endWeek: !isCustom ? int.parse(weeks[1]) : null,
      classesName: !isCustom ? json['comboClassName'].split(',') : null,
      isEleven: json['three'] == 'y',
      oddEven: _oddEven,
    );
    if (_c.isEleven && _c.time == "90") _c.time = "911";

    final Iterable<Map<String, Color>> courses =
        CourseAPI.coursesColor.where((course) => course.containsKey(_c.name));
    if (courses.isNotEmpty) {
      _c.color = courses.elementAt(0)[_c.name];
    } else {
      uniqueColor(_c, CourseAPI.randomCourseColor());
    }
    return _c;
  }

  static void uniqueColor<bool>(Course course, Color color) {
    Iterable<Map<String, Color>> courses =
        CourseAPI.coursesColor.where((course) => course.containsValue(color));
    if (courses.isNotEmpty) {
      uniqueColor(course, CourseAPI.randomCourseColor());
    } else {
      course.color = color;
      CourseAPI.coursesColor.add({"${course.name}": color});
    }
  }

  @override
  String toString() {
    return "Course ${JsonEncoder.withIndent("  ").convert({
      'name': name,
      'time': time,
      'room': location,
      'className': className,
      'teacher': teacher,
      'day': day,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'classesName': classesName,
      'isEleven': isEleven,
      'oddEven': oddEven,
    })}";
  }
}
