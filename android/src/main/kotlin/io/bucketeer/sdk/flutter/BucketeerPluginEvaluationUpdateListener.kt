package io.bucketeer.sdk.flutter

import io.bucketeer.sdk.android.BKTClient
import io.flutter.plugin.common.EventChannel

class BucketeerPluginEvaluationUpdateListener : BKTClient.EvaluationUpdateListener,
  EventChannel.StreamHandler {

  private var eventSink: EventChannel.EventSink? = null

  override fun onUpdate() {
    eventSink?.success(true)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}