///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/11/4 14:55
///
// ignore_for_file: avoid_renaming_method_parameters
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class LoadingBase extends LoadingMoreBase<Map<String, dynamic>> {
  LoadingBase({
    @required this.request,
    @required this.contentFieldName,
    this.lastIdBuilder,
  }) : assert(contentFieldName != null);

  final Future<Response<Map<String, dynamic>>> Function(int id) request;
  final String contentFieldName;
  final int Function(Map<String, dynamic> data) lastIdBuilder;

  int lastId = 0;
  int total;
  bool canRequestMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => canRequestMore;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    canRequestMore = true;
    lastId = 1;
    total = null;
    forceRefresh = !clearBeforeRequest;
    final bool result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      final Response<Map<String, dynamic>> response = await request(
        isLoadMoreAction ? lastId : 0,
      );
      final Map<String, dynamic> data = response.data;
      if (!isLoadMoreAction) {
        clear();
      }
      final List<dynamic> contents = data[contentFieldName] as List<dynamic>;
      addAll(List<Map<String, dynamic>>.from(contents));
      total = data['total'].toString().toInt();
      if (total > 0) {
        if (lastIdBuilder != null) {
          lastId = lastIdBuilder(data);
        } else {
          lastId =
              (last ?? <String, dynamic>{})['id']?.toString()?.toInt() ?? 0;
        }
      }
      canRequestMore = total > length;
      setState();
      return true;
    } catch (e) {
      LogUtils.e('Error when loading data for LoadingBase list: $e');
      return false;
    }
  }
}
