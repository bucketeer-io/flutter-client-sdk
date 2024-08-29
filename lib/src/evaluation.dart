import 'package:bucketeer_flutter_client_sdk/src/value_parser.dart';
import 'package:flutter/foundation.dart';

@immutable
class BKTEvaluationDetails<T extends Object> {
  const BKTEvaluationDetails({
    required this.featureId,
    required this.featureVersion,
    required this.userId,
    required this.variationId,
    required this.variationName,
    required this.variationValue,
    required this.reason,
  });

  final String featureId;
  final int featureVersion;
  final String userId;
  final String variationId;
  final String variationName;
  final T variationValue;
  final String reason;

  @override
  bool operator ==(Object other) {
    final bool isSameType = other is BKTEvaluationDetails<T>;
    if (isSameType == false) {
      return false;
    }
    final otherAsBKTEvaluationDetails = other as BKTEvaluationDetails<T>;
    final bool isRuntimeTypeEqual =
        runtimeType == otherAsBKTEvaluationDetails.runtimeType;
    final bool isFeatureIdEqual =
        featureId == otherAsBKTEvaluationDetails.featureId;
    final bool isFeatureVersionEqual =
        featureVersion == otherAsBKTEvaluationDetails.featureVersion;
    final bool isUserIdEqual = userId == otherAsBKTEvaluationDetails.userId;
    final bool isVariationIdEqual =
        variationId == otherAsBKTEvaluationDetails.variationId;
    final bool isVariationNameEqual =
        variationName == otherAsBKTEvaluationDetails.variationName;
    final bool isVariationValueEqual =
        variationValue == otherAsBKTEvaluationDetails.variationValue;
    final bool isReasonEqual = reason == otherAsBKTEvaluationDetails.reason;

    return isSameType &&
        isRuntimeTypeEqual &&
        isFeatureIdEqual &&
        isFeatureVersionEqual &&
        isUserIdEqual &&
        isVariationIdEqual &&
        isVariationNameEqual &&
        isVariationValueEqual &&
        isReasonEqual;
  }

  @override
  int get hashCode =>
      featureId.hashCode ^
      featureVersion.hashCode ^
      userId.hashCode ^
      variationId.hashCode ^
      variationName.hashCode ^
      variationValue.hashCode ^
      reason.hashCode;

  @override
  String toString() {
    return 'Evaluation{featureId: $featureId, '
        'featureVersion: $featureVersion, userId: $userId, '
        'variationId: $variationId, variationName: $variationName, '
        'variationValue: $variationValue, '
        'reason: $reason}';
  }

  static BKTEvaluationDetails<T> fromJson<T extends Object>(
      Map<String, dynamic> json,
      {TypeConverter<T>? converter}) {
    final valueTypeConverter = converter ?? DefaultTypeConverter();
    return BKTEvaluationDetails<T>(
      featureId: json['featureId'],
      featureVersion: json['featureVersion'],
      userId: json['userId'],
      variationId: json['variationId'],
      variationName: json['variationName'],
      // throw exception if type does not match
      variationValue: valueTypeConverter.parse(json['variationValue']),
      reason: json['reason'],
    );
  }

  static BKTEvaluationDetails<T> createDefaultValue<T extends Object>(
      String featureId, String userId, T defaultValue) {
    return BKTEvaluationDetails<T>(
      featureId: featureId,
      featureVersion: 0,
      userId: userId,
      variationId: '',
      variationName: '',
      variationValue: defaultValue,
      reason: evaluationDetailsDefaultReason,
    );
  }

  static const evaluationDetailsDefaultReason = 'CLIENT';
}

@Deprecated("use BKTEvaluationDetails<String> instead")
@immutable
class BKTEvaluation extends BKTEvaluationDetails<String> {
  final String id;

  const BKTEvaluation(
      {required this.id,
      required super.featureId,
      required super.featureVersion,
      required super.userId,
      required super.variationId,
      required super.variationName,
      required super.variationValue,
      required super.reason});

  @override
  bool operator ==(Object other) =>
      super == other && other is BKTEvaluation && id == other.id;

  @override
  int get hashCode => id.hashCode ^ super.hashCode;

  @override
  String toString() {
    return 'BKTEvaluation{id: $id, ${super.toString()}';
  }
}
