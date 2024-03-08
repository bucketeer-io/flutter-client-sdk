import 'package:flutter/foundation.dart';

@immutable
class BKTUser {
  const BKTUser._({
    required this.id,
    required this.attributes,
  });

  final String id;
  final Map<String, String> attributes;

  @override
  bool operator ==(Object other) =>
      other is BKTUser &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      mapEquals(attributes, other.attributes);

  @override
  int get hashCode => id.hashCode ^ attributes.hashCode;

  @override
  String toString() {
    return 'BucketeerUser{id: $id, data: $attributes}';
  }
}

class BKTUserBuilder {
  String _id = "";
  Map<String, String> _attributes = {};

  BKTUserBuilder id(String id) {
    _id = id;
    return this;
  }

  BKTUserBuilder customAttributes(Map<String, String> data) {
    _attributes = data;
    return this;
  }

  /// Create an [BKTUser] from the current configuration of the builder.
  /// Throws a [ArgumentError] if the `id` empty.
  BKTUser build() {
    if (_id.isEmpty) {
      throw ArgumentError("userId is required");
    }
    return BKTUser._(id: _id, attributes: _attributes);
  }
}
