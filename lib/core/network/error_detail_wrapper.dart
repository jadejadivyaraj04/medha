// lib/core/network/error_detail_wrapper.dart

import 'package:dio/dio.dart';

class ErrorDetailWrapper {
  const ErrorDetailWrapper({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  factory ErrorDetailWrapper.fromDioError(DioException error) {
    final response = error.response;
    var message = 'Something went wrong. Please try again.';

    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final apiMessage = data['message'] ?? data['error'];
      if (apiMessage != null) {
        message = apiMessage.toString();
      }
    } else if (error.message != null && error.message!.isNotEmpty) {
      message = error.message!;
    }

    return ErrorDetailWrapper(
      message: message,
      statusCode: response?.statusCode,
      code: error.type.name,
    );
  }

  factory ErrorDetailWrapper.unknown([String? detail]) {
    return ErrorDetailWrapper(
      message: detail ?? 'Something went wrong. Please try again.',
    );
  }

  @override
  String toString() => message;
}
