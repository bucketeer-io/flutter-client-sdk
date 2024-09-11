import 'package:flutter/foundation.dart';
import 'evaluation_details.dart';

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