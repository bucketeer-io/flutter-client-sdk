import 'package:flutter/foundation.dart';

import 'exception.dart';

@immutable
class BKTResult<T> {
  const BKTResult._(this._result);

  const BKTResult.success({T? data}) : this._(data);

  BKTResult.failure(
    String message, {
    BKTException? exception,
  }) : this._(Failure(message, exception: exception));

  final Object? _result;

  bool get isSuccess => !isFailure;

  bool get isFailure => _result is Failure;

  Success<T> get asSuccess => Success<T>(_result as T);

  Failure get asFailure => _result as Failure;

  void ifSuccess(void Function(T value) action) {
    if (isSuccess) {
      action(_result as T);
    }
  }

  void ifFailure(void Function(String message, Exception? exception) action) {
    if (isFailure) {
      final failure = _result as Failure;
      final message = failure.message;
      final exception = failure.exception;
      action(message, exception);
    }
  }

  @override
  String toString() => isSuccess ? 'Success($_result)' : _result.toString();

  @override
  int get hashCode => runtimeType.hashCode ^ _result.hashCode;

  @override
  bool operator ==(Object other) =>
      other is BKTResult && other._result == _result;
}

@immutable
class Success<T> {
  const Success(this.data);

  final T data;
}

@immutable
class Failure {
  const Failure(this.message, {this.exception});
  final BKTException? exception;
  final String message;

  @override
  String toString() => '[message ($message) - ${exception.toString()}]';
}
