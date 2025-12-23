import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'custom_error.freezed.dart';

@freezed
sealed class CustomError with _$CustomError {
  factory CustomError({
    @Default('') String code,
    @Default('') String message,
    @Default('') String plugin,
  }) = _CustomError;
}
