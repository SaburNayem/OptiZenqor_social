typedef HttpDataDecoder<T> = T Function(dynamic data);

class HttpServiceModel<T> {
  const HttpServiceModel({
    required this.endpoint,
    required this.method,
    required this.statusCode,
    required this.message,
    this.data,
    this.rawData,
    this.headers = const <String, String>{},
  });

  final String endpoint;
  final String method;
  final int statusCode;
  final String message;
  final T? data;
  final dynamic rawData;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  HttpServiceModel<R> copyWith<R>({
    String? endpoint,
    String? method,
    int? statusCode,
    String? message,
    R? data,
    dynamic rawData,
    Map<String, String>? headers,
  }) {
    return HttpServiceModel<R>(
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      data: data,
      rawData: rawData ?? this.rawData,
      headers: headers ?? this.headers,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'message': message,
      'data': data,
      'rawData': rawData,
      'headers': headers,
      'isSuccess': isSuccess,
    };
  }
}
