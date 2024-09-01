package io.bucketeer.sdk.flutter

import androidx.annotation.VisibleForTesting

internal enum class CallMethods {
  Initialize,
  StringVariation,
  StringVariationDetails,
  IntVariation,
  IntVariationDetails,
  DoubleVariation,
  DoubleVariationDetails,
  BoolVariation,
  BoolVariationDetails,
  JsonVariation,
  ObjectVariation,
  ObjectVariationDetails,
  Track,
  CurrentUser,
  UpdateUserAttributes,
  FetchEvaluations,
  Flush,
  EvaluationDetails,
  AddProxyEvaluationUpdateListener,
  Destroy,
  Unknown;

  companion object {
    private val avoidInitializationAssertions = listOf(
      Initialize,
      Destroy
    )

    fun shouldAssertInitialize(methods: CallMethods): Boolean {
      return !avoidInitializationAssertions.contains(methods);
    }
  }
}
