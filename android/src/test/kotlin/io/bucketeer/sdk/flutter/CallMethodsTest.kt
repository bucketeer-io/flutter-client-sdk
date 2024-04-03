package io.bucketeer.sdk.flutter

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CallMethodsTest {

  @Test
  fun `should not assert initialization`() {
    assertFalse(CallMethods.shouldAssertInitialize(CallMethods.Initialize))
    assertFalse(CallMethods.shouldAssertInitialize(CallMethods.Destroy))
  }

  @Test
  fun `should assert other methods`() {
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.StringVariation))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.IntVariation))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.DoubleVariation))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.BoolVariation))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.JsonVariation))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.Track))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.CurrentUser))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.UpdateUserAttributes))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.FetchEvaluations))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.Flush))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.EvaluationDetails))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.AddProxyEvaluationUpdateListener))
    assertTrue(CallMethods.shouldAssertInitialize(CallMethods.Unknown))
  }
}
