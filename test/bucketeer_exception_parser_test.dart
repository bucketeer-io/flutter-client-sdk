import 'package:bucketeer_flutter_client_sdk/src/exception.dart';
import 'package:bucketeer_flutter_client_sdk/src/exception_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntToBKTException tests', () {
    final testCases = [
      {'input': 1, 'exceptionType': RedirectRequestException},
      {'input': 2, 'exceptionType': BKTBadRequestException},
      {'input': 3, 'exceptionType': BKTUnauthorizedException},
      {'input': 4, 'exceptionType': BKTForbiddenException},
      {'input': 5, 'exceptionType': BKTFeatureNotFoundException},
      {'input': 6, 'exceptionType': BKTClientClosedRequestException},
      {'input': 7, 'exceptionType': BKTInvalidHttpMethodException},
      {'input': 8, 'exceptionType': PayloadTooLargeException},
      {'input': 9, 'exceptionType': BKTInternalServerErrorException},
      {'input': 10, 'exceptionType': BKTServiceUnavailableException},
      {'input': 11, 'exceptionType': BKTTimeoutException},
      {'input': 12, 'exceptionType': BKTNetworkException},
      {'input': 13, 'exceptionType': BKTIllegalArgumentException},
      {'input': 14, 'exceptionType': BKTIllegalStateException},
      {'input': 15, 'exceptionType': BKTUnknownException},
      {'input': 0, 'exceptionType': BKTUnknownException},
    ];

    for (var testCase in testCases) {
      test('Converts ${testCase['input']} to ${testCase['exceptionType']}', () {
        final exception =
            (testCase['input'] as int).toBKTException('Test message');
        expect(exception.runtimeType, testCase['exceptionType']);
        expect(exception.message, 'Test message');
      });
    }
  });

  group('ObjectToBKTException tests', () {
    test('Object is a BKTException', () {
      final exception = RedirectRequestException(message: 'Test message');
      final result = exception.toBKTResultFailure<String>();
      expect(result.isFailure, true);
      expect(result.asFailure.message, 'Test message');
      expect(result.asFailure.exception, isA<RedirectRequestException>());
    });

    test('Object is an Exception', () {
      final exception = Exception('Test message');
      final result = exception.toBKTResultFailure<String>();
      expect(result.isFailure, true);
      expect(result.asFailure.message, 'Exception: Test message');
      expect(result.asFailure.exception, isA<BKTUnknownException>());
    });

    test('Object is neither BKTException nor Exception', () {
      final object = Object();
      final result = object.toBKTResultFailure<String>();
      expect(result.isFailure, true);
      expect(result.asFailure.message, object.toString());
      expect(result.asFailure.exception, isA<BKTUnknownException>());
    });
  });

  group('ParseBKTException tests', () {
    test('Map contains errorCode and errorMessage is String', () {
      final map = {'errorCode': 1, 'errorMessage': 'Test message'};
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<RedirectRequestException>());
      expect(exception.message, 'Test message');
    });

    test('Map contains errorCode and errorMessage is not String', () {
      final map = {'errorCode': 1, 'errorMessage': 123}; // Not a string
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<RedirectRequestException>());
      expect(exception.message, '123');
    });

    test('Map contains errorCode but errorMessage is null', () {
      final map = {'errorCode': 1}; // No errorMessage provided
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<RedirectRequestException>());
      expect(exception.message, 'unknown');
    });

    test('Map does not contain errorCode', () {
      final map = {'errorMessage': 'Test message'}; // No errorCode provided
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<BKTUnknownException>());
      expect(exception.message, 'Test message');
    });

    test('Map does not contain errorCode and errorMessage', () {
      final map =
          <String, dynamic>{}; // Neither errorCode nor errorMessage provided
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<BKTUnknownException>());
      expect(exception.message, 'unknown');
    });

    test('Map contains errorCode and errorMessage is null', () {
      final map = {
        'errorCode': 1,
        'errorMessage': null
      }; // errorMessage is null
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<RedirectRequestException>());
      expect(exception.message, 'unknown');
    });

    test('Map contains errorCode but errorMessage is empty', () {
      final map = {'errorCode': 1, 'errorMessage': ''}; // errorMessage is empty
      final exception = map.parseBKTException();
      expect(exception, const TypeMatcher<RedirectRequestException>());
      expect(exception.message, '');
    });
  });
}
