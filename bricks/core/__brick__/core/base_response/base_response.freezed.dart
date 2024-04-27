// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BaseResponse _$BaseResponseFromJson(
  Map<String, dynamic> json,
) {
  return _BaseResponse.fromJson(
    json,
  );
}

/// @nodoc
mixin _$BaseResponse {
  String? get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable()
class _$BaseResponseImpl implements _BaseResponse {
  const _$BaseResponseImpl({this.status, this.message});

  factory _$BaseResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$$BaseResponseImplFromJson(
        json,
      );

  @override
  final String? status;
  @override
  final String? message;

  @override
  String toString() {
    return 'BaseResponse(status: $status, message: $message)';
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseResponseImplToJson(
      this,
    );
  }
}

abstract class _BaseResponse implements BaseResponse {
  const factory _BaseResponse({final String? status, final String? message}) =
      _$BaseResponseImpl;

  factory _BaseResponse.fromJson(
    Map<String, dynamic> json,
  ) = _$BaseResponseImpl.fromJson;

  @override
  String? get status;
  @override
  String? get message;
}
