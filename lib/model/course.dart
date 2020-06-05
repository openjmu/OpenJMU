///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:55
///
part of 'models.dart';

/// 课程实体
///
/// [isCustom] **必需**是否自定义课程,
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称,
/// [teacher] 教师名称, [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周,
/// [classesName] 共同上课的班级, [isEleven] 是否第十一节,
///
/// [rawDay] 原始天数 [rawTime] 原始课时
/// 以上两项用于编辑课程信息。由于课程表的数据错乱，需要保存原始数据，否则会造成编辑错误。
@HiveType(typeId: HiveAdapterTypeIds.course)
class Course {
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
    this.rawDay,
    this.rawTime,
  });

  factory Course.fromJson(Map<String, dynamic> json, {bool isCustom = false}) {
    json.forEach((String k, dynamic _) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    final int _oddEven = !isCustom ? judgeOddEven(json) : null;
    final List<String> weeks =
        !isCustom ? (json['allWeek'] as String).split(' ')[0].split('-') : null;

    String _name;
    if (isCustom) {
      try {
        _name = Uri.decodeComponent(json['content']?.toString());
      } catch (e) {
        _name = json['content']?.toString();
      }
    } else {
      _name = json['couName']?.toString() ?? '(空)';
    }

    String _time;
    if (isCustom) {
      _time = timeHandler(json['courseTime']);
    } else {
      _time = timeHandler(json['coudeTime']);
    }

    final Course _c = Course(
      isCustom: isCustom,
      name: _name,
      time: _time,
      location: json['couRoom']?.toString(),
      className: json['className']?.toString(),
      teacher: json['couTeaName']?.toString(),
      day: json[isCustom ? 'courseDaytime' : 'couDayTime']
          .toString()
          .substring(0, 1)
          .toInt(),
      startWeek: !isCustom ? weeks[0].toInt() : null,
      endWeek: !isCustom ? weeks[1].toInt() : null,
      classesName:
          !isCustom ? json['comboClassName']?.toString()?.split(',') : null,
      isEleven: json['three'] == 'y',
      oddEven: _oddEven,
      rawDay:
          json[isCustom ? 'courseDaytime' : 'couDayTime'].toString().toInt(),
      rawTime: json[isCustom ? 'courseTime' : 'coudeTime'].toString(),
    );
    if (_c.isEleven && _c.time == '90') {
      _c.time = '911';
    }
    uniqueColor(_c, CourseAPI.randomCourseColor());
    return _c;
  }

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
  @HiveField(12)
  int rawDay;
  @HiveField(13)
  String rawTime;
  Color color;

  /// Whether we should use raw data to modify.
  bool get shouldUseRaw => day != rawDay || time != rawTime;

  static int judgeOddEven(Map<String, dynamic> json) {
    int _oddEven = 0;
    final List<String> _split = (json['allWeek'] as String).split(' ');
    if (_split.length > 1) {
      switch (_split[1]) {
        case '单周':
          _oddEven = 1;
          break;
        case '双周':
          _oddEven = 2;
          break;
      }
    }
    return _oddEven;
  }

  static void uniqueColor(Course course, Color color) {
    final CourseColor _courseColor = CourseAPI.coursesUniqueColor.firstWhere(
      (CourseColor courseColor) => courseColor.name == course.name,
      orElse: () => null,
    );
    if (_courseColor != null) {
      course.color = _courseColor.color;
    } else {
      final List<CourseColor> courses = CourseAPI.coursesUniqueColor
          .where((CourseColor c) => c.color == color)
          .toList();

      if (courses.isNotEmpty) {
        uniqueColor(course, CourseAPI.randomCourseColor());
      } else {
        course.color = color;
        CourseAPI.coursesUniqueColor
            .add(CourseColor(name: course.name, color: color));
      }
    }
  }

  /// Convert time due to inconsistent data.
  static String timeHandler(dynamic time) {
    assert(time != null, 'Time of course cannot be null.');
    String courseTime = '0';
    switch (time.toString()) {
      case '1':
      case '2':
      case '12':
      case '23':
        courseTime = '1';
        break;
      case '3':
      case '4':
      case '34':
      case '45':
        courseTime = '3';
        break;
      case '5':
      case '6':
      case '56':
      case '67':
        courseTime = '5';
        break;
      case '7':
      case '8':
      case '78':
      case '89':
        courseTime = '7';
        break;
      case '90':
      case '911':
      case '9':
      case '10':
        courseTime = '9';
        break;
      case '11':
        courseTime = '11';
        break;
    }
    return courseTime;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isCustom': isCustom,
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
    };
  }

  @override
  String toString() {
    return 'Course ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}

@immutable
class CourseColor {
  const CourseColor({this.name, this.color});

  final String name;
  final Color color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseColor &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'CourseColor ($name, $color)';
  }
}
