// 🐦 Flutter imports:

// Flutter imports:

// Package imports:
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  DioClient();

  static Future<Dio?> getDio() async {
    Dio? dio = Dio();

    dio.options.connectTimeout = const Duration(milliseconds: 15000);
    dio.options.receiveTimeout = const Duration(milliseconds: 15000);

    // ITS DEBUG MODE SO PRINT APP LOGS
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      error: true,
      logPrint: (object) => print(object.toString()),
      request: true,
      compact: true,
      responseBody: true,
      responseHeader: true,
    ));

    RetryInterceptor(
      dio: dio,
      retryableExtraStatuses: {400, 301, 300, 501},
      logPrint: (message) => print(message),
      retries: 2,
    );

    dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));

    return dio;
  }
}
