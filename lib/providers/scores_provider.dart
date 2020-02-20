///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-21 11:33
///
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class ScoresProvider extends ChangeNotifier {
  final Box<Map<dynamic, dynamic>> _scoreBox = HiveBoxes.scoresBox;

  Socket _socket;
  String _scoreData = '';

  bool _loaded = false;
  bool get loaded => _loaded;
  set loaded(bool value) {
    assert(value != null);
    if (value == _loaded) {
      return;
    }
    _loaded = value;
    notifyListeners();
  }

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    assert(value != null);
    if (value == _loading) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  bool _loadError = false;
  bool get loadError => _loadError;
  String _errorString = '';
  String get errorString => _errorString;

  List<String> _terms;
  List<String> get terms => _terms;
  set terms(List<String> value) {
    assert(value != null);
    if (value == _terms) {
      return;
    }
    _terms = List<String>.from(value);
    notifyListeners();
  }

  String _selectedTerm;
  String get selectedTerm => _selectedTerm;
  set selectedTerm(String value) {
    assert(value != null);
    if (value == _selectedTerm) {
      return;
    }
    _selectedTerm = value;
    notifyListeners();
  }

  bool get hasScore => _scores?.isNotEmpty ?? false;

  List<Score> _scores;
  List<Score> get scores => _scores;
  set scores(List<Score> value) {
    assert(value != null);
    if (value == _scores) {
      return;
    }
    _scores = List<Score>.from(value);
    notifyListeners();
  }

  List<Score> get filteredScores =>
      _scores?.filter((Score score) => score.termId == _selectedTerm)?.toList();

  Future<void> initScore() async {
    final Map<String, dynamic> data = _scoreBox.get(currentUser.uid)?.cast<String, dynamic>();
    if (data != null && data['terms'] != null && data['scores'] != null) {
      _terms = (data['terms'] as List<dynamic>).cast<String>();
      _scores = (data['scores'] as List<dynamic>).cast<Score>();
      _loaded = true;
    }
    if (await initSocket()) {
      requestScore();
    }
  }

  Future<bool> initSocket() async {
    try {
      _socket = await Socket.connect(API.openjmuHost, 4000);
      _socket
        ..setOption(SocketOption.tcpNoDelay, true)
        ..timeout(2.minutes);
      _socket.listen(onReceive, onDone: destroySocket);
      debugPrint('Score socket connect success.');
      return true;
    } catch (e) {
      _loading = false;
      _loadError = true;
      _errorString = e.toString();
      debugPrint('Score socket connect error: $e');
      return false;
    }
  }

  Future<void> requestScore() async {
    if (!loading) {
      loading = true;
    }
    try {
      _socket?.add(jsonEncode(<String, dynamic>{
        'uid': '${currentUser.uid}',
        'sid': '${currentUser.sid}',
        'workid': '${currentUser.workId}',
      }).toUtf8());
    } catch (e) {
      if (e.toString().contains('StreamSink is closed')) {
        if (await initSocket()) {
          requestScore();
        }
      } else {
        loading = false;
        debugPrint('Error when request score: $e');
      }
    }
  }

  void onReceive(List<int> data) {
    final String value = utf8.decode(data);
    _scoreData += value;
    if (_scoreData.endsWith(']}}')) {
      tryDecodeScores();
    }
  }

  void tryDecodeScores() {
    try {
      final Map<String, dynamic> response =
          (jsonDecode(_scoreData) as Map<String, dynamic>)['obj'] as Map<String, dynamic>;
      if ((response['terms'] as List<dynamic>).isNotEmpty &&
          (response['scores'] as List<dynamic>).isNotEmpty) {
        final List<Score> scoreList = <Score>[];
        _terms = List<String>.from(response['terms'] as List<dynamic>);
        _selectedTerm = _terms.last;
        for (final dynamic score in response['scores'] as List<dynamic>) {
          scoreList.add(Score.fromJson(score as Map<String, dynamic>));
        }
        if (_scores != scoreList) {
          _scores = scoreList;
        }
      }
      updateScoreCache();
      if (_loadError) {
        _loadError = false;
      }
      if (!_loaded) {
        _loaded = true;
      }
      _loading = false;
      notifyListeners();
      debugPrint('Scores decoded successfully with ${_scores?.length ?? 0} scores.');
      _scoreData = '';
    } catch (e) {
      debugPrint('Decode scores response error: $e');
    }
  }

  Future<void> updateScoreCache() async {
    final Map<String, dynamic> beforeData = _scoreBox.get(currentUser.uid)?.cast<String, dynamic>();
    if (beforeData == null || beforeData['scores'] != _scores) {
      final Map<String, dynamic> presentData = <String, dynamic>{
        'terms': _terms,
        'scores': _scores,
      };
      await _scoreBox.put(currentUser.uid, presentData);
      debugPrint('Scores cache updated successfully.');
    } else {
      debugPrint('Scores cache don\'t need to update.');
    }
  }

  void selectTerm(int index) {
    if (_selectedTerm != _terms[index]) {
      selectedTerm = _terms[index];
    }
  }

  void unloadScore() {
    _loaded = false;
    _loading = true;
    _loadError = false;
    _terms = null;
    _selectedTerm = null;
    _scores = null;
    _scoreData = '';
  }

  void destroySocket() {
    _socket?.close();
    _socket?.destroy();
  }

  @override
  void dispose() {
    unloadScore();
    destroySocket();
    super.dispose();
  }
}

const Map<String, Map<String, double>> fiveBandScale = <String, Map<String, double>>{
  '优秀': <String, double>{'score': 95.0, 'point': 4.625},
  '良好': <String, double>{'score': 85.0, 'point': 3.875},
  '中等': <String, double>{'score': 75.0, 'point': 3.125},
  '及格': <String, double>{'score': 65.0, 'point': 2.375},
  '不及格': <String, double>{'score': 55.0, 'point': 0.0},
};
const Map<String, Map<String, double>> twoBandScale = <String, Map<String, double>>{
  '合格': <String, double>{'score': 80.0, 'point': 3.5},
  '不合格': <String, double>{'score': 50.0, 'point': 0.0},
};
