// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../dio_response/dio_response.dart';
import 'api_consumer.dart';
import 'dio_factory.dart';

// import '../injector/injector.dart';

class DioConsumer implements ApiConsumer {
  @override
  Future<DioBaseResponse> downloadFile(
      {Map<String, dynamic>? headers,
      ProgressCallback? progressCallback,
      bool? isAuth = true,
      bool processResponse = true,
      required String url,
      required savePath}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        // headers!.putIfAbsent('Authorization ', () => 'Bearer $authToken');
      }

      final apiResponse = await response!.download(url, savePath,
          options: Options(headers: headers),
          onReceiveProgress: progressCallback);
      final httpResponse = _buildResponse(apiResponse);
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> uploadMultipleFilesViaFromBytes(
      {Map<String, dynamic>? headers,
      bool processResponse = true,
      bool? isAuth = true,
      required Map<String, dynamic> fields,
      // required List<FileUploadByte> fileList,
      required String url}) async {
    List<FileUploadByte> fileList = [];
    var formData = FormData.fromMap(fields);
    for (var file in fileList) {
      formData.files.add(MapEntry(
          'dataFiles',
          MultipartFile.fromBytes(
            file.bytesData!,
            filename: file.filename,
          )));
    }

    try {
      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final response = await DioClient.getDio();

      final apiResponse = await response!.post(url,
          options: Options(headers: headers),
          data: formData,
          onSendProgress: (int sent, int total) {});
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);

      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  // upload Single File
  @override
  Future<DioBaseResponse> uploadSingleFile(
      {Map<String, dynamic>? headers,
      bool? isAuth = true,
      required String url,
      required String key,
      required String filePath,
      bool processResponse = true}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();
      const authToken = "";

      if (isAuth == true) {
        headers = {
          'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.post(url,
          options: Options(headers: headers),
          data:
              FormData.fromMap({key: await MultipartFile.fromFile(filePath)}));
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> delete(
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      bool processResponse = true,
      required String url}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.delete(url,
          options: Options(headers: headers), queryParameters: params);
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> get(
      {Duration? cacheAge,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      bool processResponse = true,
      required String url}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.get(url,
          options: Options(headers: headers), queryParameters: params);

      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> patch(
      {required Map<String, dynamic> data,
      Map<String, dynamic>? headers,
      bool? isAuth = true,
      Map<String, dynamic>? params,
      bool processResponse = true,
      required String url}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.patch(url,
          data: data,
          options: Options(headers: headers),
          queryParameters: params);
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> post(
      {Duration? cacheAge,
      Map<String, dynamic>? data,
      Map<String, dynamic>? headers,
      bool? isAuth = true,
      Map<String, dynamic>? params,
      bool processResponse = true,
      required String url}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.post(url,
          data: data,
          options: Options(headers: headers),
          queryParameters: params);
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DioBaseResponse> put(
      {required Map<String, dynamic> data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      bool? isAuth = true,
      bool processResponse = true,
      required String url}) async {
    try {
      final response = await DioClient.getDio();

      // final authToken = await sl<AuthLocalDataSource>().getAccessToken();

      if (isAuth == true) {
        headers = {
          // 'Authorization': 'Bearer $authToken',
        };
      }

      final apiResponse = await response!.put(url,
          data: data,
          options: Options(headers: headers),
          queryParameters: params);
      final httpResponse = _buildResponse(apiResponse);
      if (processResponse) {}
      return httpResponse;
    } on DioException catch (e, stackTrace) {
      final errResponse = _buildResponseWithError(e, stackTrace);
      if (processResponse && e.response != null) {}
      return errResponse;
    } catch (e) {
      rethrow;
    }
  }

  DioBaseResponse _buildResponse(Response response) {
    return DioBaseResponse(
        data: response.data, statusCode: response.statusCode ?? 400);
  }

  DioBaseResponse _buildResponseWithError(
      DioException error, StackTrace stackTrace) {
    if (error.response?.statusCode != 401) {}

    return DioBaseResponse(
        data: error.response?.data,
        //DIO ERROR SO ITS AN ERROR FROM RESPONSE OF THE API OR FROM DIO ITSELF
        message: _dioError(error),
        statusCode: error.response?.statusCode ?? 400);
  }
}

_dioError(DioException error) {
  if (error.response?.data == null) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';

      case DioExceptionType.sendTimeout:
        return 'Request timed out';

      case DioExceptionType.receiveTimeout:
        return 'Response timeout';

      case DioExceptionType.unknown:
        return 'Unknown error';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.cancel:
        return 'request cancelled';

      case DioExceptionType.badCertificate:
        return 'bad certificate';

      case DioExceptionType.badResponse:
        try {
          int? errCode = error.response?.statusCode;
          switch (errCode) {
            case 400:
              return 'Request timed out'; //dioRequestSyntax

            case 403:
              return 'Server refused to execute'; //dioServerRefusedToExecute

            case 404:
              return 'Server refused to execute'; //dioNotConnectServer

            case 405:
              return 'Request method is forbidden'; //dioRequestForbidden

            case 500:
              return 'Server internal error'; //dioServerInternal

            case 502:
              return 'Invalid request'; //dioInvalidRequest

            case 503:
              return 'Server is down'; //dioServerDown

            case 505:
              return 'Does not support HTTP protocol request'; //dioHttpNotSupport

            default:
              return 'Unknown mistake'; //dioUnknownMistake
          }
        } on Exception catch (_) {
          return 'Unknown error'; //dioUnknownError
        }

      default:
        return error.message;
    }
  } else {
    var decodeResponse = error.response!.data;
    if (error.response!.data != null) {
      if (decodeResponse['message'] != null) {
        return decodeResponse['message'];
      } else if (decodeResponse['error'] != null) {
        return decodeResponse['error'];
      } else {
        return 'An unexpected error occurred, please try again';
      }
    } else {
      return decodeResponse.statusMessage;
    }
  }
}

Future<void> processResponse(DioBaseResponse response) async {
  if (response.statusCode == 401) {}
}
