abstract class BKTException implements Exception {
  final String message;

  BKTException({required this.message});

  @override
  int get hashCode => runtimeType.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      other.hashCode == hashCode &&
      other is BKTException &&
      other.message == message;
}

class RedirectRequestException extends BKTException {
  RedirectRequestException({required String message}) : super(message: message);
}

class BKTBadRequestException extends BKTException {
  BKTBadRequestException({required String message}) : super(message: message);
}

class BKTUnauthorizedException extends BKTException {
  BKTUnauthorizedException({required String message}) : super(message: message);
}

class BKTForbiddenException extends BKTException {
  BKTForbiddenException({required String message}) : super(message: message);
}

class BKTFeatureNotFoundException extends BKTException {
  BKTFeatureNotFoundException({required String message})
      : super(message: message);
}

class BKTClientClosedRequestException extends BKTException {
  BKTClientClosedRequestException({required String message})
      : super(message: message);
}

class BKTInvalidHttpMethodException extends BKTException {
  BKTInvalidHttpMethodException({required String message})
      : super(message: message);
}

class PayloadTooLargeException extends BKTException {
  PayloadTooLargeException({required String message}) : super(message: message);
}

class BKTInternalServerErrorException extends BKTException {
  BKTInternalServerErrorException({required String message})
      : super(message: message);
}

class BKTServiceUnavailableException extends BKTException {
  BKTServiceUnavailableException({required String message})
      : super(message: message);
}

class BKTTimeoutException extends BKTException {
  BKTTimeoutException({required String message}) : super(message: message);
}

class BKTNetworkException extends BKTException {
  BKTNetworkException({required String message}) : super(message: message);
}

class BKTIllegalArgumentException extends BKTException {
  BKTIllegalArgumentException({required String message})
      : super(message: message);
}

class BKTIllegalStateException extends BKTException {
  BKTIllegalStateException({required String message}) : super(message: message);
}

class BKTUnknownException extends BKTException {
  BKTUnknownException({required String message, Exception? exception})
      : super(message: message);
}
