// @dart = 2.9
///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-15 11:54
///
part of 'providers.dart';

class ReportRecordsProvider extends ChangeNotifier {
  Set<int> _records;
  Set<int> get records => _records;
  set records(Set<int> value) {
    _records = Set<int>.from(value);
    notifyListeners();
  }

  void initRecords() {
    _records =
        HiveBoxes.reportRecordBox.get(currentUser.uid)?.toSet()?.cast<int>() ??
            <int>{};
  }

  Future<bool> addRecord(int postId) async {
    if (_records.contains(postId)) {
      showToast('不能重复举报噢~');
      return false;
    } else {
      _records.add(postId);
      await HiveBoxes.reportRecordBox
          .put(currentUser.uid, List<int>.from(_records));
      return true;
    }
  }

  void unloadRecords() {
    _records = null;
  }
}
