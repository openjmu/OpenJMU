///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-21 11:33
///
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class ScoresProvider extends ChangeNotifier {
  final _scoreBox = HiveBoxes.scoresBox;

  Socket _socket;
  String _scoreData = '';

  bool _loaded = false;
  bool get loaded => _loaded;
  set loaded(bool value) {
    assert(value != null);
    if (value == _loaded) return;
    _loaded = value;
    notifyListeners();
  }

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    assert(value != null);
    if (value == _loading) return;
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
    if (value == _terms) return;
    _terms = List.from(value);
    notifyListeners();
  }

  String _selectedTerm;
  String get selectedTerm => _selectedTerm;
  set selectedTerm(String value) {
    assert(value != null);
    if (value == _selectedTerm) return;
    _selectedTerm = value;
    notifyListeners();
  }

  bool get hasScore => _scores?.isNotEmpty ?? false;
  List<Score> _scores;
  List<Score> get scores => _scores;
  set scores(List<Score> value) {
    assert(value != null);
    if (value == _scores) return;
    _scores = List.from(value);
    notifyListeners();
  }

  List get filteredScores => _scores?.filter((score) => score.termId == _selectedTerm)?.toList();

  void initScore() async {
    final data = _scoreBox.get(currentUser.uid)?.cast<String, dynamic>();
    if (data != null && data['terms'] != null && data['scores'] != null) {
      _terms = (data['terms'] as List).cast<String>();
      _scores = (data['scores'] as List).cast<Score>();
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

  void requestScore() {
    _socket?.add(utf8.encode(jsonEncode({
      'uid': '${currentUser.uid}',
      'sid': '${currentUser.sid}',
      'workid': '${currentUser.workId}',
    })));
  }

  void onReceive(data) async {
    final value = utf8.decode(data);
    _scoreData += value;
    if (_scoreData.endsWith(']}}')) tryDecodeScores();
  }

  void tryDecodeScores() {
    try {
      final response = jsonDecode(_scoreData)['obj'];
      if (response['terms'].length > 0 && response['scores'].length > 0) {
        final scoreList = <Score>[];
        _terms = List<String>.from(response['terms']);
        _selectedTerm = _terms.last;
        response['scores'].forEach((score) {
          scoreList.add(Score.fromJson(score));
        });
        if (_scores != scoreList) _scores = scoreList;
      }
      updateScoreCache();
      if (_loadError) _loadError = false;
      if (!_loaded) _loaded = true;
      _loading = false;
      notifyListeners();
      debugPrint('Scores decoded successfully with ${_scores?.length ?? 0} scores.');
    } catch (e) {
      debugPrint('Decode scores response error: $e');
    }
  }

  void updateScoreCache() async {
    final beforeData = _scoreBox.get(currentUser.uid)?.cast<String, dynamic>();
    if (beforeData == null || beforeData['scores'] != _scores) {
      final presentData = {'terms': _terms, 'scores': _scores};
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

const fiveBandScale = <String, Map<String, double>>{
  '优秀': {'score': 95.0, 'point': 4.625},
  '良好': {'score': 85.0, 'point': 3.875},
  '中等': {'score': 75.0, 'point': 3.125},
  '及格': {'score': 65.0, 'point': 2.375},
  '不及格': {'score': 55.0, 'point': 0.0},
};
const twoBandScale = <String, Map<String, double>>{
  '合格': {'score': 80.0, 'point': 3.5},
  '不合格': {'score': 50.0, 'point': 0.0},
};
