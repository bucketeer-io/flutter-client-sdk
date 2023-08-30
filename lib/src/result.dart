import 'package:flutter/foundation.dart';

@immutable
class BKTResult<T> {
  const BKTResult._(this._result);

  const BKTResult.success({T? data}) : this._(data);

  BKTResult.failure(String message) : this._(Failure(message));

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

  void ifFailure(void Function(String message) action) {
    if (isFailure) {
      final message = (_result as Failure).message;
      action(message);
    }
  }

  @override
  String toString() => isSuccess ? 'Success($_result)' : _result.toString();

  @override
  int get hashCode => runtimeType.hashCode ^ _result.hashCode;

  @override
  bool operator ==(Object other) => other is BKTResult && other._result == _result;
}

@immutable
class Success<T> {
  const Success(this.data);

  final T data;
}

@immutable
class Failure {
  const Failure(this.message);

  final String message;
}
