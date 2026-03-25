class ServiceResponseModel<T> {
  const ServiceResponseModel({
    required this.endpoint,
    required this.statusCode,
    required this.data,
    this.message,
  });

  final String endpoint;
  final int statusCode;
  final T data;
  final String? message;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'endpoint': endpoint,
      'statusCode': statusCode,
      'data': data,
      'message': message,
    };
  }
}
