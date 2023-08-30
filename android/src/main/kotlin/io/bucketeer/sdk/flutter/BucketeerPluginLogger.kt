package io.bucketeer.sdk.flutter

import android.util.Log
import io.bucketeer.sdk.android.BKTLogger

class BucketeerPluginLogger(
  private val tag: String = "BucketeerPlugin",
) : BKTLogger {
  override fun log(
    priority: Int,
    messageCreator: (() -> String?)?,
    throwable: Throwable?,
  ) {
    if (!Log.isLoggable(tag, priority)) return

    val message = buildString {
      messageCreator?.invoke()?.let { append(it) }
      if (throwable != null) append("\n")
      if (throwable != null) append(Log.getStackTraceString(throwable))
    }
    if (message.isBlank()) return

    Log.println(priority, tag, message)
  }
}
