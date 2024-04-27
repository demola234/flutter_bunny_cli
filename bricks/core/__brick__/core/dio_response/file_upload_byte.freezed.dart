// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_upload_byte.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FileUploadByte {
  List<int>? get bytesData => throw _privateConstructorUsedError;
  String? get filename => throw _privateConstructorUsedError;
}

/// @nodoc

class _$FileUploadByteImpl extends _FileUploadByte {
  const _$FileUploadByteImpl({final List<int>? bytesData, this.filename})
      : _bytesData = bytesData,
        super._();

  final List<int>? _bytesData;
  @override
  List<int>? get bytesData {
    final value = _bytesData;
    if (value == null) return null;
    if (_bytesData is EqualUnmodifiableListView) return _bytesData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? filename;

  @override
  String toString() {
    return 'FileUploadByte(bytesData: $bytesData, filename: $filename)';
  }
}

abstract class _FileUploadByte extends FileUploadByte {
  const factory _FileUploadByte(
      {final List<int>? bytesData,
      final String? filename}) = _$FileUploadByteImpl;
  const _FileUploadByte._() : super._();

  @override
  List<int>? get bytesData;
  @override
  String? get filename;
}
