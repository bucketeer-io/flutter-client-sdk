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
  RedirectRequestException({required super.message});
}

class BKTBadRequestException extends BKTException {
  BKTBadRequestException({required super.message});
}

class BKTUnauthorizedException extends BKTException {
  BKTUnauthorizedException({required super.message});
}

class BKTForbiddenException extends BKTException {
  BKTForbiddenException({required super.message});
}

class BKTFeatureNotFoundException extends BKTException {
  BKTFeatureNotFoundException({required super.message});
}

class BKTClientClosedRequestException extends BKTException {
  BKTClientClosedRequestException({required super.message});
}

class BKTInvalidHttpMethodException extends BKTException {
  BKTInvalidHttpMethodException({required super.message});
}

class PayloadTooLargeException extends BKTException {
  PayloadTooLargeException({required super.message});
}

class BKTInternalServerErrorException extends BKTException {
  BKTInternalServerErrorException({required super.message});
}

class BKTServiceUnavailableException extends BKTException {
  BKTServiceUnavailableException({required super.message});
}

class BKTTimeoutException extends BKTException {
  BKTTimeoutException({required super.message});
}

class BKTNetworkException extends BKTException {
  BKTNetworkException({required super.message});
}

class BKTIllegalArgumentException extends BKTException {
  BKTIllegalArgumentException({required super.message});
}

class BKTIllegalStateException extends BKTException {
  BKTIllegalStateException({required super.message});
}

class BKTUnknownException extends BKTException {
  BKTUnknownException({required super.message, Exception? exception});
}
