import 'exception_parser.dart';
import 'exception.dart';
import 'result.dart';

Future<T> valueGuard<T>(Map<String, dynamic> result,
    {T Function(Map<String, dynamic>)? customMapping}) async {
  if (result['status']) {
    if (result['response'] != null) {
      try {
        if (customMapping != null) {
          // throw runtime exception
          return customMapping(
            Map<String, dynamic>.from(result['response']),
          );
        } else {
          // throw runtime exception
          return result['response'] as T;
        }
      } catch (ex) {
        throw BKTUnknownException(
            message: ex.toString(), exception: ex is Exception ? ex : null);
      }
    } else {
      throw BKTUnknownException(message: 'missing result response');
    }
  } else {
    throw result.parseBKTException();
  }
}

// _resultGuard for handle any native func will throw the BKTException
BKTResult<T> resultGuard<T>(Map<String, dynamic> result,
    {T Function(Map<String, dynamic>)? customMapping}) {
  try {
    if (result['status']) {
      if (result['response'] != null) {
        if (customMapping != null) {
          return BKTResult<T>.success(
            data: customMapping(
              Map<String, dynamic>.from(result['response']),
            ),
          );
        } else {
          return BKTResult<T>.success(data: result['response']);
        }
      } else {
        throw BKTUnknownException(message: 'missing result response');
      }
    } else {
      final exception = result.parseBKTException();
      return BKTResult.failure(exception.message, exception: exception);
    }
  } catch (ex) {
    // catch runtime exception when parse the result
    final exception = BKTUnknownException(
        message: ex.toString(), exception: ex is Exception ? ex : null);
    return BKTResult.failure(exception.message, exception: exception);
  }
}

// _statusGuard checking and parser the status only
Future<BKTResult<void>> statusGuard<T>(Map<String, dynamic> result) async {
  if (!result['status']) {
    return result.parseBKTException().toBKTResultFailure();
  }
  return const BKTResult<void>.success();
}
