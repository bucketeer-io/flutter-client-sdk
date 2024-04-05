import 'package:bucketeer_flutter_client_sdk/src/exception.dart';
import 'package:bucketeer_flutter_client_sdk/src/exception_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BKTExceptionType', () {
    test('fromInt should return corresponding enum value', () {
      expect(BKTExceptionType.fromInt(0), equals(BKTExceptionType.unknown));
      expect(BKTExceptionType.fromInt(1),
          equals(BKTExceptionType.redirectRequest));
      expect(BKTExceptionType.fromInt(2), equals(BKTExceptionType.badRequest));
      expect(
          BKTExceptionType.fromInt(3), equals(BKTExceptionType.unauthorized));
      expect(BKTExceptionType.fromInt(4), equals(BKTExceptionType.forbidden));
      expect(BKTExceptionType.fromInt(5),
          equals(BKTExceptionType.featureNotFound));
      expect(BKTExceptionType.fromInt(6),
          equals(BKTExceptionType.clientClosedRequest));
      expect(BKTExceptionType.fromInt(7),
          equals(BKTExceptionType.invalidHttpMethod));
      expect(BKTExceptionType.fromInt(8),
          equals(BKTExceptionType.payloadTooLarge));
      expect(BKTExceptionType.fromInt(9),
          equals(BKTExceptionType.internalServerError));
      expect(BKTExceptionType.fromInt(10),
          equals(BKTExceptionType.serviceUnavailable));
      expect(BKTExceptionType.fromInt(11), equals(BKTExceptionType.timeout));
      expect(BKTExceptionType.fromInt(12), equals(BKTExceptionType.network));
      expect(BKTExceptionType.fromInt(13),
          equals(BKTExceptionType.illegalArgumentException));
      expect(BKTExceptionType.fromInt(14),
          equals(BKTExceptionType.illegalStateException));
      expect(BKTExceptionType.fromInt(15),
          equals(BKTExceptionType.nativeUnknownException));
    });

    test('fromInt should return unknown for out-of-range values', () {
      expect(BKTExceptionType.fromInt(-1), equals(BKTExceptionType.unknown));
      expect(BKTExceptionType.fromInt(16), equals(BKTExceptionType.unknown));
    });
  });

  group('BKTException', () {
    test('Test BKTException equality', () {
      final exception1 = BKTBadRequestException(message: 'error message here');
      final exception2 = BKTBadRequestException(message: 'error message here');
      final exception3 =
          BKTUnauthorizedException(message: 'error message here');

      expect(exception1 == exception2, true,
          reason: "Same type and message, should be equal");
      expect(exception1 == exception3, false,
          reason: "Different type, should not be equal");
    });

    test('Test BKTException hashCode', () {
      final exception1 =
          BKTInternalServerErrorException(message: 'Internal Server Error');
      final exception2 =
          BKTInternalServerErrorException(message: 'Internal Server Error');
      final exception3 =
          BKTInternalServerErrorException(message: 'Internal Server Error 3');

      expect(exception1.hashCode == exception2.hashCode, true,
          reason: ' Hash codes should match for equal objects');
      expect(exception1.hashCode == exception3.hashCode, false,
          reason: ' Hash codes should not match');
    });

    /// Add more tests for other exception classes as needed
  });
}
