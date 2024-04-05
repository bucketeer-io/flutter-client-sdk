import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/exception.dart';
import 'package:bucketeer_flutter_client_sdk/src/native_channel_result_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statusGuard', () {
    test('should return success if status is true', () async {
      final result = await statusGuard<void>({'status': true});
      expect(result.isSuccess, true);
    });

    test('should return Failure if status is false', () async {
      final result = await statusGuard<void>({'status': false});
      expect(result.isSuccess, false);
      expect(result.asFailure.exception, isA<BKTUnknownException>());
    });

    /// Add more test cases as needed
    test('should return Failure if status is a redirect', () async {
      final result = await statusGuard<void>({'status': false, 'errorCode': 1});
      expect(result.isSuccess, false);
      expect(result.asFailure.exception, isA<RedirectRequestException>());
    });

    test('should return Failure if status is a bad request', () async {
      final result = await statusGuard<void>({'status': false, 'errorCode': 2});
      expect(result.isSuccess, false);
      expect(result.asFailure.exception, isA<BKTBadRequestException>());
    });
  });

  group('resultGuard function', () {
    test('returns success when status is true', () {
      final result = {
        'status': true,
        'response': {'key': 'value'}
      };

      final actualResult = resultGuard<Map<String, dynamic>>(result);
      expect(actualResult.isSuccess, true);
      expect(actualResult.asSuccess.data, {'key': 'value'});
    });

    test('returns failure when status is false', () {
      final result = {'status': false, 'error': 'Some error message'};
      final actualResult = resultGuard<String>(result);
      expect(actualResult.isFailure, true);
      expect(actualResult.asFailure.exception, isA<BKTUnknownException>());
    });

    test('returns failure when result response is missing', () {
      final result = {
        'status': true,
      };

      final actualResult = resultGuard<String>(result);
      expect(actualResult.isFailure, true);
      expect(actualResult.asFailure.exception, isA<BKTUnknownException>());
    });

    test('returns failure with BKTBadRequestException', () {
      final result = {'status': false, 'errorCode': 2};

      final actualResult = resultGuard<String>(result);
      expect(actualResult.isFailure, true);
      expect(actualResult.asFailure.exception, isA<BKTBadRequestException>());
    });

    test('returns success with custom mapping', () {
      final result = {
        'status': true,
        'response': {'key': 'value'}
      };

      final actualResult = resultGuard<Map<String, dynamic>>(
        result,
        customMapping: (response) {
          return {'custom_key': response['key']};
        },
      );
      expect(actualResult.isSuccess, true);
      expect(actualResult.asSuccess.data, {'custom_key': 'value'});
    });

    test(
        'returns failure with unknown exception if custom mapping throws an error',
        () {
      final result = {
        'status': true,
        'response': {'key': 'value'}
      };

      final actualResult = resultGuard<String>(
        result,
        customMapping: (response) {
          throw Exception('Error during custom mapping');
        },
      );

      expect(actualResult.isFailure, true);
      expect(actualResult.asFailure.exception, isA<BKTUnknownException>());
    });

    test(
        'resultGuard function should throw BKTUnknownException when error data is correct',
        () {
      final result = {'status': false, 'errorCode': '2', 'errorMessage': 2};

      final actualResult = resultGuard<String>(result);
      expect(actualResult.isFailure, true);
      expect(actualResult.asFailure.exception, isA<BKTUnknownException>());
    });
  });

  group('valueGuard function tests', () {
    test('valueGuard function should return correct result when status is true',
        () {
      final result = {
        'status': true,
        'response': 'some_data',
      };

      expect(() async {
        final data = await valueGuard<String>(result);
        expect(data, 'some_data');
      }, returnsNormally);
    });

    test(
        'valueGuard function should throw BKTUnknownException when custom mapping throws exception',
        () {
      final result = {
        'status': true,
        'response': 'some_data',
      };

      expect(() async {
        await valueGuard<String>(
          result,
          customMapping: (data) {
            throw Exception('Custom mapping failed');
          },
        );
      }, throwsA(isA<BKTUnknownException>()));
    });

    test(
        'valueGuard function should throw BKTUnknownException when result response is missing',
        () {
      final result = {
        'status': true,

        /// 'response': 'some_data', /// Commented out to simulate a missing response
      };

      expect(() async {
        await valueGuard<String>(result);
      }, throwsA(isA<BKTUnknownException>()));
    });

    test(
        'valueGuard function should throw BKTUnknownException when error data is correct',
        () {
      final result = {
        'status': false,
        'errorCode': 'Forbidden',
        'errorMessage': 2,
      };

      expect(() async {
        await valueGuard<String>(result);
      }, throwsA(isA<BKTUnknownException>()));
    });

    test('valueGuard function should throw BKTException when status is false',
        () {
      final result = {
        'status': false,
        'errorCode': 2,
        'errorMessage': 'Forbidden',
      };

      expect(() async {
        await valueGuard<String>(result);
      }, throwsA(isA<BKTBadRequestException>()));
    });

    /// Add more tests as needed for different scenarios
  });
}
