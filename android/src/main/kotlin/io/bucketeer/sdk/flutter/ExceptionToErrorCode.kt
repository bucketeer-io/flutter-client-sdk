package io.bucketeer.sdk.flutter

import io.bucketeer.sdk.android.BKTException

fun Exception.toErrorCode(): Int {
  return when (this) {
    is BKTException -> {
      when (this) {
        // Do NOT change the error code
        is BKTException.RedirectRequestException -> 1
        is BKTException.BadRequestException -> 2
        is BKTException.UnauthorizedException -> 3
        is BKTException.ForbiddenException -> 4
        is BKTException.FeatureNotFoundException -> 5
        is BKTException.ClientClosedRequestException -> 6
        is BKTException.InvalidHttpMethodException -> 7
        is BKTException.PayloadTooLargeException -> 8
        is BKTException.InternalServerErrorException -> 9
        is BKTException.ServiceUnavailableException -> 10
        is BKTException.TimeoutException -> 11
        is BKTException.NetworkException -> 12
        is BKTException.IllegalArgumentException -> 13
        is BKTException.IllegalStateException -> 14
        is BKTException.UnknownException,
        is BKTException.UnknownServerException -> 15
      }
    }
    else -> 0
  }
}
