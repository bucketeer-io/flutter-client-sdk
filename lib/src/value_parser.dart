import 'package:bucketeer_flutter_client_sdk/src/value.dart';

abstract class TypeConverter<T> {
  T parse(dynamic);
}

class DefaultTypeConverter<T> implements TypeConverter<T> {
  @override
  T parse(dynamic) {
    // Throw runtime exception
    return dynamic as T;
  }
}

class BKTValueTypeConverter implements TypeConverter<BKTValue> {
  const BKTValueTypeConverter();

  @override
  BKTValue parse(dynamic) {
    return BKTValue.fromJson(dynamic);
  }
}
