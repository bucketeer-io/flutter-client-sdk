import 'package:flutter/foundation.dart';

abstract class BKTValue {
  const BKTValue();

  // Factory method for decoding from JSON
  factory BKTValue.fromJson(dynamic json) {
    if (json is String) {
      return BKTString(json);
    } else if (json is num) {
      // This covers both int and double
      return BKTNumber(json.toDouble());
    } else if (json is bool) {
      return BKTBoolean(json);
    } else if (json is List) {
      return BKTList(json.map((e) => BKTValue.fromJson(e)).toList());
    } else if (json is Map) {
      return BKTStructure(json.map(
          (key, value) => MapEntry(key.toString(), BKTValue.fromJson(value))));
    } else if (json == null) {
      return const BKTNull();
    } else {
      throw FormatException("Cannot decode BKTValue: $json");
    }
  }

  // Method to encode the value back to JSON
  dynamic toJson();

  // Type-safe casting methods
  bool? asBoolean() => null;
  String? asString() => null;
  int? asInteger() => null;
  double? asDouble() => null;
  List<BKTValue>? asList() => null;
  Map<String, BKTValue>? asDictionary() => null;

  @override
  String toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BKTValue) return false;
    return runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class BKTBoolean extends BKTValue {
  final bool value;

  const BKTBoolean(this.value);

  @override
  bool? asBoolean() => value;

  @override
  dynamic toJson() => value;

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTBoolean &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class BKTString extends BKTValue {
  final String value;

  const BKTString(this.value);

  @override
  String? asString() => value;

  @override
  dynamic toJson() => value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class BKTNumber extends BKTValue {
  final double value;

  const BKTNumber(this.value);

  @override
  double? asDouble() => value;

  @override
  int? asInteger() => value.toInt();

  @override
  dynamic toJson() => value;

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTNumber &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class BKTList extends BKTValue {
  final List<BKTValue> value;

  const BKTList(this.value);

  @override
  List<BKTValue>? asList() => value;

  @override
  dynamic toJson() => value.map((e) => e.toJson()).toList();

  @override
  String toString() => value.map((e) => e.toString()).toList().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTList &&
          runtimeType == other.runtimeType &&
          _listEquals(value, other.value);

  @override
  int get hashCode => value.hashCode;

  bool _listEquals(List<BKTValue> a, List<BKTValue> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class BKTStructure extends BKTValue {
  final Map<String, BKTValue> value;

  const BKTStructure(this.value);

  @override
  Map<String, BKTValue>? asDictionary() => value;

  @override
  dynamic toJson() => value.map((key, value) => MapEntry(key, value.toJson()));

  @override
  String toString() =>
      value.map((key, value) => MapEntry(key, value.toString())).toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTStructure &&
          runtimeType == other.runtimeType &&
          mapEquals(value, other.value);

  @override
  int get hashCode => value.hashCode;
}

class BKTNull extends BKTValue {
  const BKTNull();

  @override
  dynamic toJson() => null;

  @override
  String toString() => 'null';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BKTNull && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
