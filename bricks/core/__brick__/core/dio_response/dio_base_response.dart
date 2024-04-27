// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dio_base_response.freezed.dart';

@Freezed(copyWith: false, equal: false)
class DioBaseResponse with _$DioBaseResponse {
  const factory DioBaseResponse(
      {final int? statusCode,
      final String? message,
      final dynamic data}) = _DioBaseResponse;

  const DioBaseResponse._();
}
