// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../dio_response/dio_response.dart';

abstract class ApiConsumer {
  Future<DioBaseResponse> get(
      {Duration? cacheAge,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      required String url});

  Future<DioBaseResponse> patch(
      {required Map<String, dynamic> data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      required String url});

  Future<DioBaseResponse> post(
      {Duration? cacheAge,
      Map<String, dynamic>? data,
      Map<String, dynamic>? headers,
      bool? isAuth = true,
      Map<String, dynamic>? params,
      required String url});

  Future<DioBaseResponse> put(
      {required Map<String, dynamic> data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      required String url});

  Future<DioBaseResponse> delete(
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      required String url});

  Future<DioBaseResponse> downloadFile(
      {Map<String, dynamic>? headers,
      ProgressCallback? progressCallback,
      bool? isAuth = true,
      required String url,
      required savePath});

  Future<DioBaseResponse> uploadMultipleFilesViaFromBytes({
    Map<String, dynamic>? headers,
    bool? isAuth = true,
    required String url,
    bool processResponse = true,
    required Map<String, dynamic> fields,
    // required List<FileUploadByte> fileList,
  });

  Future<DioBaseResponse> uploadSingleFile(
      {Map<String, dynamic>? headers,
      bool? isAuth = true,
      required String url,
      required String key,
      required String filePath,
      bool processResponse = true});
}
