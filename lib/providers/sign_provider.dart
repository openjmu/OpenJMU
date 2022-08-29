///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-09 19:26
///
part of 'providers.dart';

class SignProvider extends ChangeNotifier {
  bool get isSigning => _isSigning;
  bool _isSigning = false;

  set isSigning(bool value) {
    if (value == _isSigning) {
      return;
    }
    _isSigning = value;
    notifyListeners();
  }

  bool get hasSigned => _hasSigned;
  bool _hasSigned = false;

  set hasSigned(bool value) {
    if (value == _hasSigned) {
      return;
    }
    _hasSigned = value;
    notifyListeners();
  }

  int get signedCount => _signedCount;
  int _signedCount = 0;

  set signedCount(int value) {
    if (value == _signedCount) {
      return;
    }
    _signedCount = value;
    notifyListeners();
  }

  /// 获取签到状态
  Future<void> getSignStatus() async {
    try {
      final bool signed = (await SignAPI.getTodayStatus()).data!['status'] == 1;
      final int count =
          ((await SignAPI.getSignList()).data!['signdata']?.length ?? 0) as int;
      _hasSigned = signed;
      _signedCount = count;
      // Automatically run sign request if the user is not signed.
      if (!_hasSigned) {
        requestSign();
      }
    } catch (e) {
      LogUtil.e('Failed when fetching sign status: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 请求签到
  Future<void> requestSign() async {
    isSigning = true;
    try {
      await SignAPI.requestSign();
      _hasSigned = true;
      _signedCount++;
      showToast('签到成功');
    } catch (e) {
      LogUtil.e('Failed when requesting sign: $e');
      showErrorToast('签到失败');
    } finally {
      _isSigning = false;
      notifyListeners();
    }
  }

  /// 重置签到状态
  void resetSignStatus() {
    _isSigning = false;
    _hasSigned = false;
    _signedCount = 0;
    notifyListeners();
  }
}
