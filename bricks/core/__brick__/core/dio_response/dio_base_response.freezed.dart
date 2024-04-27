// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dio_base_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DioBaseResponse {
  int? get statusCode => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;
}

/// @nodoc

class _$DioBaseResponseImpl extends _DioBaseResponse {
  const _$DioBaseResponseImpl({this.statusCode, this.message, this.data})
      : super._();

  @override
  final int? statusCode;
  @override
  final String? message;
  @override
  final dynamic data;

  @override
  String toString() {
    return 'DioBaseResponse(statusCode: $statusCode, message: $message, data: $data)';
  }
}

abstract class _DioBaseResponse extends DioBaseResponse {
  const factory _DioBaseResponse(
      {final int? statusCode,
      final String? message,
      final dynamic data}) = _$DioBaseResponseImpl;
  const _DioBaseResponse._() : super._();

  @override
  int? get statusCode;
  @override
  String? get message;
  @override
  dynamic get data;
}
