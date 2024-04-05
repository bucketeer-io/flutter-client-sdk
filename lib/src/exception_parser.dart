import 'exception.dart';
import 'result.dart';

extension ObjectToBKTException on Object {
  BKTResult<T> toBKTResultFailure<T>() {
    if (this is BKTException) {
      return BKTResult<T>.failure((this as BKTException).message,
          exception: this as BKTException);
    }
    final exception = BKTUnknownException(
        message: toString(),
        exception: this is Exception ? this as Exception : null);
    return BKTResult<T>.failure(exception.message, exception: exception);
  }
}

extension ParseBKTException on Map<String, dynamic> {
  BKTException parseBKTException() {
    final errorCode = this['errorCode'];
    final errorMessage = this['errorMessage'] ?? "unknown";
    final typedErrorMessage =
        errorMessage is String ? errorMessage : errorMessage.toString();
    if (errorCode is int) {
      return errorCode.toBKTException(typedErrorMessage);
    }
    return BKTUnknownException(message: typedErrorMessage);
  }
}

enum BKTExceptionType {
  /// 0
  unknown,

  /// 1
  redirectRequest,

  /// 2
  badRequest,

  /// 3
  unauthorized,

  /// 4
  forbidden,

  /// 5
  featureNotFound,

  /// 6
  clientClosedRequest,

  /// 7
  invalidHttpMethod,

  /// 8
  payloadTooLarge,

  /// 9
  internalServerError,

  /// 10
  serviceUnavailable,

  /// 11
  timeout,

  /// 12
  network,

  /// 13
  illegalArgumentException,

  /// 14
  illegalStateException,

  /// 15
  nativeUnknownException;

  static BKTExceptionType fromInt(int value) {
    if (value <= 0 || value >= BKTExceptionType.values.length) {
      return BKTExceptionType.unknown;
    }
    return BKTExceptionType.values[value];
  }
}

extension IntToBKTException on int {
  BKTException toBKTException(String errorMessage) {
    final type = BKTExceptionType.fromInt(this);
    switch (type) {
      case BKTExceptionType.redirectRequest:
        return RedirectRequestException(message: errorMessage);
      case BKTExceptionType.badRequest:
        return BKTBadRequestException(message: errorMessage);
      case BKTExceptionType.unauthorized:
        return BKTUnauthorizedException(message: errorMessage);
      case BKTExceptionType.forbidden:
        return BKTForbiddenException(message: errorMessage);
      case BKTExceptionType.featureNotFound:
        return BKTFeatureNotFoundException(message: errorMessage);
      case BKTExceptionType.clientClosedRequest:
        return BKTClientClosedRequestException(message: errorMessage);
      case BKTExceptionType.invalidHttpMethod:
        return BKTInvalidHttpMethodException(message: errorMessage);
      case BKTExceptionType.payloadTooLarge:
        return PayloadTooLargeException(message: errorMessage);
      case BKTExceptionType.internalServerError:
        return BKTInternalServerErrorException(message: errorMessage);
      case BKTExceptionType.serviceUnavailable:
        return BKTServiceUnavailableException(message: errorMessage);
      case BKTExceptionType.timeout:
        return BKTTimeoutException(message: errorMessage);
      case BKTExceptionType.network:
        return BKTNetworkException(message: errorMessage);
      case BKTExceptionType.illegalArgumentException:
        return BKTIllegalArgumentException(message: errorMessage);
      case BKTExceptionType.illegalStateException:
        return BKTIllegalStateException(message: errorMessage);
      case BKTExceptionType.nativeUnknownException:
        return BKTUnknownException(message: errorMessage);
      default:
        return BKTUnknownException(message: errorMessage);
    }
  }
}
