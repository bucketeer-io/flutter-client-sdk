import 'package:flutter/foundation.dart';

@immutable
class BKTEvaluationDetails<T extends Object> {
  const BKTEvaluationDetails({
    required this.id,
    required this.featureId,
    required this.featureVersion,
    required this.userId,
    required this.variationId,
    required this.variationName,
    required this.variationValue,
    required this.reason,
  });

  final String id;
  final String featureId;
  final int featureVersion;
  final String userId;
  final String variationId;
  final String variationName;
  final T variationValue;
  final String reason;

  @override
  bool operator ==(Object other) =>
      other is BKTEvaluationDetails &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      featureId == other.featureId &&
      featureVersion == other.featureVersion &&
      userId == other.userId &&
      variationId == other.variationId &&
      variationName == other.variationName &&
      variationValue == other.variationValue &&
      reason == other.reason;

  @override
  int get hashCode =>
      id.hashCode ^
      featureId.hashCode ^
      featureVersion.hashCode ^
      userId.hashCode ^
      variationId.hashCode ^
      variationName.hashCode ^
      variationValue.hashCode ^
      reason.hashCode;

  @override
  String toString() {
    return 'Evaluation{id: $id, featureId: $featureId, '
        'featureVersion: $featureVersion, userId: $userId, '
        'variationId: $variationId, variationName: $variationName, '
        'variationValue: $variationValue, '
        'reason: $reason}';
  }
}

@Deprecated("use BKTEvaluationDetails<String> instead")
@immutable
class BKTEvaluation extends BKTEvaluationDetails<String> {
  const BKTEvaluation(
      {required super.id,
      required super.featureId,
      required super.featureVersion,
      required super.userId,
      required super.variationId,
      required super.variationName,
      required super.variationValue,
      required super.reason});
}
