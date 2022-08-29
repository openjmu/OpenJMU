///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-21 11:33
///
part of 'providers.dart';

class ScoresProvider extends ChangeNotifier {
  final Box<Map<dynamic, dynamic>> _scoreBox = HiveBoxes.scoresBox;

  final List<int> _rawData = <int>[];
  Socket? _socket;
  String _scoreData = '';

  final int _maximumRetries = 3;
  int _retries = 0;

  bool get loaded => _loaded;
  bool _loaded = false;

  set loaded(bool value) {
    if (value == _loaded) {
      return;
    }
    _loaded = value;
    notifyListeners();
  }

  bool get loading => _loading;
  bool _loading = true;

  set loading(bool value) {
    if (value == _loading) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  bool get loadError => _loadError;
  bool _loadError = false;

  String get errorString => _errorString;
  String _errorString = '';

  List<String>? get terms => _terms;
  List<String>? _terms;

  set terms(List<String>? value) {
    if (value == _terms) {
      return;
    }
    _terms = value?.toList();
    notifyListeners();
  }

  String? get selectedTerm => _selectedTerm;
  String? _selectedTerm;

  set selectedTerm(String? value) {
    if (value == _selectedTerm) {
      return;
    }
    _selectedTerm = value;
    notifyListeners();
  }

  bool get hasScore => _scores?.isNotEmpty ?? false;

  List<Score>? get scores => _scores;
  List<Score>? _scores;

  set scores(List<Score>? value) {
    if (value == _scores) {
      return;
    }
    _scores = value?.toList();
    notifyListeners();
  }

  List<Score>? get filteredScores {
    return _scores
        ?.filter((Score score) => score.termId == _selectedTerm)
        .toList();
  }

  List<Score>? scoresByTerm(String term) {
    return _scores?.filter((Score score) => score.termId == term).toList();
  }

  Future<void> initScore() async {
    final Map<dynamic, dynamic>? data = _scoreBox.get(currentUser.uid);
    if (data != null && data['terms'] != null && data['scores'] != null) {
      _terms =
          (data['terms'] as List<dynamic>).reversed.toList().cast<String>();
      _scores = (data['scores'] as List<dynamic>).cast<Score>();
      _loading = false;
      _loaded = true;
    }
    if (await initSocket()) {
      requestScore(isInit: true);
    }
  }

  Future<bool> initSocket() async {
    try {
      _socket = await Socket.connect(API.openjmuHost, 4000);
      _socket!
        ..setOption(SocketOption.tcpNoDelay, true)
        ..timeout(2.minutes)
        ..listen(onReceive, onDone: destroySocket);
      LogUtil.d('Score socket connect success.');
      return true;
    } catch (e) {
      _loading = false;
      _loadError = true;
      _errorString = e.toString();
      LogUtil.e('Score socket connect error: $e');
      return false;
    }
  }

  Future<void> requestScore({bool isInit = false}) async {
    if (!isInit && !loading) {
      loading = true;
    }
    _rawData.clear();
    _scoreData = '';
    try {
      _socket?.add(jsonEncode(<String, dynamic>{
        'uid': currentUser.uid,
        'sid': currentUser.sid,
        'workid': currentUser.workId,
      }).toUtf8());
    } catch (e) {
      if (e.toString().contains('StreamSink is closed')) {
        if (_retries < _maximumRetries && await initSocket()) {
          _retries++;
          requestScore();
        }
      } else {
        loading = false;
        LogUtil.e('Error when request score: $e');
      }
    }
  }

  Future<void> onReceive(List<int> data) async {
    try {
      _rawData.addAll(data);
      final String value = utf8.decode(_rawData);
      _scoreData += value;
      if (_scoreData.endsWith(']}}')) {
        tryDecodeScores();
      }
    } catch (_) {}
  }

  void tryDecodeScores() {
    try {
      final Map<dynamic, dynamic> response =
          jsonDecode(_scoreData)['obj'] as Map<dynamic, dynamic>;
      if ((response['terms'] as List<dynamic>).isNotEmpty &&
          (response['scores'] as List<dynamic>).isNotEmpty) {
        final List<Score> scoreList = <Score>[];
        _terms = List<String>.from(response['terms'] as List<dynamic>);
        _selectedTerm = _terms?.lastOrNull;
        for (final dynamic score in response['scores'] as List<dynamic>) {
          scoreList.add(Score.fromJson(score as Map<String, dynamic>));
        }
        if (_scores != scoreList) {
          _scores = scoreList;
        }
      }
      _rawData.clear();
      _scoreData = '';
      updateScoreCache();
      if (_loadError) {
        _loadError = false;
      }
      if (!_loaded) {
        _loaded = true;
      }
      _loading = false;
      notifyListeners();
      LogUtil.d(
        'Scores decoded successfully with ${_scores?.length ?? 0} scores.',
      );
    } catch (e) {
      LogUtil.e('Decode scores response error: $e');
      if (_retries < _maximumRetries) {
        _retries++;
        _socket?.destroy();
        _rawData.clear();
        _scoreData = '';
        initSocket();
      }
    }
  }

  Future<void> updateScoreCache() async {
    final Map<String, dynamic>? beforeData =
        _scoreBox.get(currentUser.uid)?.cast<String, dynamic>();
    if (beforeData == null || beforeData['scores'] != _scores) {
      final Map<String, dynamic> presentData = <String, dynamic>{
        'terms': _terms,
        'scores': _scores,
      };
      await _scoreBox.put(currentUser.uid, presentData);
      LogUtil.d('Scores cache updated successfully.');
    } else {
      LogUtil.d('Scores cache don\'t need to update.');
    }
  }

  void selectTerm(String term) {
    if (_selectedTerm != term) {
      selectedTerm = term;
    }
  }

  void unloadScore() {
    _retries = 0;
    _loaded = false;
    _loading = true;
    _loadError = false;
    _terms = null;
    _selectedTerm = null;
    _rawData.clear();
    _scores = null;
    _scoreData = '';
  }

  Future<void> destroySocket() async {
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
  }

  @override
  void dispose() {
    unloadScore();
    destroySocket();
    super.dispose();
  }
}

const Map<String, Map<String, double>> fiveBandScale =
    <String, Map<String, double>>{
  '优秀': <String, double>{'score': 95.0, 'point': 4.625},
  '良好': <String, double>{'score': 85.0, 'point': 3.875},
  '中等': <String, double>{'score': 75.0, 'point': 3.125},
  '及格': <String, double>{'score': 65.0, 'point': 2.375},
  '不及格': <String, double>{'score': 55.0, 'point': 0.0},
};
const Map<String, Map<String, double>> twoBandScale =
    <String, Map<String, double>>{
  '合格': <String, double>{'score': 80.0, 'point': 3.5},
  '不合格': <String, double>{'score': 50.0, 'point': 0.0},
};
