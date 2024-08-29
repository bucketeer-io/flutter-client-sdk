
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
      return BKTStructure(
          json.map((key, value) => MapEntry(key.toString(), BKTValue.fromJson(value))));
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
}

class BKTStructure extends BKTValue {
  final Map<String, BKTValue> value;

  const BKTStructure(this.value);

  @override
  Map<String, BKTValue>? asDictionary() => value;

  @override
  dynamic toJson() =>
      value.map((key, value) => MapEntry(key, value.toJson()));

  @override
  String toString() =>
      value.map((key, value) => MapEntry(key, value.toString())).toString();
}

class BKTNull extends BKTValue {
  const BKTNull();

  @override
  dynamic toJson() => null;

  @override
  String toString() => 'null';
}