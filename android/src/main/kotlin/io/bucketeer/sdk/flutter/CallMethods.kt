package io.bucketeer.sdk.flutter

import androidx.annotation.VisibleForTesting

@VisibleForTesting
internal enum class CallMethods {
  Initialize,
  StringVariation,
  IntVariation,
  DoubleVariation,
  BoolVariation,
  JsonVariation,
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
