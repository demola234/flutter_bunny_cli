// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_base_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ApiResponse<T> {
  T? get data => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
}

/// @nodoc

class _$ApiResponseImpl<T> extends _ApiResponse<T> {
  const _$ApiResponseImpl({this.data, this.message, this.status}) : super._();

  @override
  final T? data;
  @override
  final String? message;
  @override
  final String? status;

  @override
  String toString() {
    return 'ApiResponse<$T>(data: $data, message: $message, status: $status)';
  }
}

abstract class _ApiResponse<T> extends ApiResponse<T> {
  const factory _ApiResponse(
      {final T? data,
      final String? message,
      final String? status}) = _$ApiResponseImpl<T>;
  const _ApiResponse._() : super._();

  @override
  T? get data;
  @override
  String? get message;
  @override
  String? get status;
}
