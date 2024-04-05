package io.bucketeer.sdk.flutter
import io.bucketeer.sdk.android.BKTException
import org.junit.Assert.assertEquals
import org.junit.Test

class ErrorCodeConversionTest {

  @Test
  fun `test BKTException to error code conversion`() {
    val redirectException = BKTException.RedirectRequestException("Redirect error", 301)
    val badRequestException = BKTException.BadRequestException("Bad request error")
    val unauthorizedException = BKTException.UnauthorizedException("Unauthorized error")
    val forbiddenException = BKTException.ForbiddenException("Forbidden error")
    val featureNotFoundException = BKTException.FeatureNotFoundException("Feature not found error")
    val clientClosedRequestException = BKTException.ClientClosedRequestException("Client closed request error")
    val invalidHttpMethodException = BKTException.InvalidHttpMethodException("Invalid HTTP method error")
    val payloadTooLargeException = BKTException.PayloadTooLargeException("Payload too large error")
    val internalServerErrorException = BKTException.InternalServerErrorException("Internal server error")
    val serviceUnavailableException = BKTException.ServiceUnavailableException("Service unavailable error")
    val timeoutException = BKTException.TimeoutException("Timeout error", null, 5000)
    val networkException = BKTException.NetworkException("Network error", Throwable())
    val illegalArgumentException = BKTException.IllegalArgumentException("Illegal argument error")
    val illegalStateException = BKTException.IllegalStateException("Illegal state error")
    val unknownException = BKTException.UnknownException("Unknown error")
    val unknownServerException = BKTException.UnknownServerException("Unknown server error", null, 500)

    assertEquals(1, redirectException.toErrorCode())
    assertEquals(2, badRequestException.toErrorCode())
    assertEquals(3, unauthorizedException.toErrorCode())
    assertEquals(4, forbiddenException.toErrorCode())
    assertEquals(5, featureNotFoundException.toErrorCode())
    assertEquals(6, clientClosedRequestException.toErrorCode())
    assertEquals(7, invalidHttpMethodException.toErrorCode())
    assertEquals(8, payloadTooLargeException.toErrorCode())
    assertEquals(9, internalServerErrorException.toErrorCode())
    assertEquals(10, serviceUnavailableException.toErrorCode())
    assertEquals(11, timeoutException.toErrorCode())
    assertEquals(12, networkException.toErrorCode())
    assertEquals(13, illegalArgumentException.toErrorCode())
    assertEquals(14, illegalStateException.toErrorCode())
    assertEquals(15, unknownException.toErrorCode())
    assertEquals(15, unknownServerException.toErrorCode())
  }

  @Test
  fun `test non-BKTException to error code conversion`() {
    val exception = Exception("Generic error")

    assertEquals(0, exception.toErrorCode())
  }
}
