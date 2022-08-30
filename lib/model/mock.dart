import 'dart:convert';

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class MockModel {
  MockModel({
    this.request,
    this.response,
  });

  factory MockModel.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : MockModel(
          request: MockRequest.fromJson(
              asT<Map<String, dynamic>>(jsonRes['request'])),
          response: MockResponse.fromJson(
              asT<Map<String, dynamic>>(jsonRes['response'])),
        );

  MockRequest request;
  MockResponse response;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'request': request,
        'response': response,
      };

  MockModel copy() {
    return MockModel(
      request: request?.copy(),
      response: response?.copy(),
    );
  }
}

class MockRequest {
  MockRequest({
    this.headers,
    this.query,
    this.data,
  });

  factory MockRequest.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : MockRequest(
          headers: asT<Object>(jsonRes['headers']),
          query: asT<Map<String, dynamic>>(
              jsonRes['query'] as Map<String, dynamic>),
          data: asT<Object>(jsonRes['data']),
        );

  Object headers;
  Map<String, dynamic> query;
  Object data;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'headers': headers,
        'query': query,
        'data': data,
      };

  MockRequest copy() {
    return MockRequest(
      headers: headers,
      query: query,
      data: data,
    );
  }
}

class MockResponse {
  MockResponse({
    this.statusCode,
    this.headers,
    this.data,
  });

  factory MockResponse.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : MockResponse(
          statusCode: asT<int>(jsonRes['statusCode']),
          headers: asT<Map<String, List<String>>>(
            (jsonRes['headers'] as Map<String, dynamic>).map(
              (String key, dynamic value) => MapEntry(
                key,
                List.castFrom<dynamic, String>(<String>[...value]),
              ),
            ),
          ),
          data: asT<Object>(jsonRes['data']),
        );

  int statusCode;
  Map<String, List<String>> headers;
  Object data;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'statusCode': statusCode,
        'headers': headers,
        'data': data,
      };

  MockResponse copy() {
    return MockResponse(
      statusCode: statusCode,
      headers: headers,
      data: data,
    );
  }
}
