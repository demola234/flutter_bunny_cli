// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_base_response.freezed.dart';

@Freezed(genericArgumentFactories: true, copyWith: false, equal: false)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    final T? data,
    final String? message,
    final String? status,
  }) = _ApiResponse;

  const ApiResponse._();
}
