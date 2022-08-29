///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-18 16:52
///
part of 'providers.dart';

class DateProvider extends ChangeNotifier {
  DateProvider() {
    initCurrentWeek();
  }

  Timer? _fetchCurrentWeekTimer;

  DateTime? get startDate => _startDate;
  DateTime? _startDate;

  set startDate(DateTime? value) {
    _startDate = value;
    notifyListeners();
  }

  int get currentWeek => _currentWeek;
  int _currentWeek = 0;

  set currentWeek(int value) {
    _currentWeek = value;
    notifyListeners();
  }

  int? get difference => _difference;
  int? _difference;

  set difference(int? value) {
    _difference = value;
    notifyListeners();
  }

  Future<void> initCurrentWeek() async {
    final DateTime? _dateInCache = HiveBoxes.startWeekBox.get('startDate');
    if (_dateInCache != null) {
      _startDate = _dateInCache;
      _handleCurrentWeek();
    }
    await getCurrentWeek();
  }

  Future<void> updateStartDate(DateTime date) async {
    _startDate = date;
    await HiveBoxes.startWeekBox.put('startDate', date);
  }

  void _handleCurrentWeek() {
    final int _d = _startDate!.difference(currentTime).inDays;
    if (_difference != _d) {
      _difference = _d;
    }
    final int _w = -((_difference! - 1) / 7).floor();
    if (_currentWeek != _w) {
      _currentWeek = _w;
      notifyListeners();
      Instances.eventBus.fire(CurrentWeekUpdatedEvent());
    }
  }

  Future<void> getCurrentWeek() async {
    final Box<DateTime> box = HiveBoxes.startWeekBox;
    try {
      DateTime? _day;
      _day = box.get('startDate');
      final Response<Map<String, dynamic>> res = await NetUtils.get(
        API.firstDayOfTerm,
      );
      final Map<String, dynamic> data = res.data!;
      final DateTime onlineDate = DateTime.parse(data['start'] as String);
      if (_day != onlineDate) {
        _day = onlineDate;
      }
      if (_startDate == null) {
        updateStartDate(_day!);
      } else {
        if (_startDate != _day) {
          updateStartDate(_day!);
        }
      }

      _handleCurrentWeek();
      _fetchCurrentWeekTimer?.cancel();
    } catch (e) {
      LogUtil.e('Failed when fetching current week: $e');
      startFetchCurrentWeekTimer();
    }
  }

  void startFetchCurrentWeekTimer() {
    _fetchCurrentWeekTimer?.cancel();
    _fetchCurrentWeekTimer = Timer.periodic(30.seconds, (_) {
      getCurrentWeek();
    });
  }
}

const Map<int, String> shortWeekdays = <int, String>{
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
};
