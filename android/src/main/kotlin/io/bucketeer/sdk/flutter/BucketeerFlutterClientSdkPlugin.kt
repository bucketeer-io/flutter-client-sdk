package io.bucketeer.sdk.flutter

import android.content.Context
import io.bucketeer.sdk.android.BKTClient
import io.bucketeer.sdk.android.BKTConfig
import io.bucketeer.sdk.android.BKTException
import io.bucketeer.sdk.android.BKTUser
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * BucketeerPlugin
 */
class BucketeerFlutterClientSdkPlugin : MethodCallHandler, FlutterPlugin {

  companion object {
    const val METHOD_CHANNEL_NAME = "io.bucketeer.sdk.plugin.flutter"
    const val EVALUATION_UPDATE_EVENT_CHANNEL_NAME =
      "$METHOD_CHANNEL_NAME::evaluation.update.listener"
  }

  private var applicationContext: Context? = null
  private var methodChannel: MethodChannel? = null
  private var evaluationUpdateEventChannel: EventChannel? = null
  private var evaluationUpdateListener = BucketeerPluginEvaluationUpdateListener()
  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
  }

  private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
    this.applicationContext = applicationContext
    methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
    methodChannel!!.setMethodCallHandler(this)
    evaluationUpdateEventChannel =
      EventChannel(messenger, EVALUATION_UPDATE_EVENT_CHANNEL_NAME).apply {
        setStreamHandler(evaluationUpdateListener)
      }
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    applicationContext = null
    methodChannel!!.setMethodCallHandler(null)
    methodChannel = null
  }

  private fun initialize(call: MethodCall, result: MethodChannel.Result) {
    val debugging = (call.argument("debugging") as? Boolean) ?: false
    val userId = call.argument("userId") as? String
    val apiKey = call.argument("apiKey") as? String
    val apiEndpoint = call.argument("apiEndpoint") as? String
    val featureTag = call.argument("featureTag") as? String
    val eventsFlushInterval =
      call.argument("eventsFlushInterval") as? Long
    val eventsMaxQueueSize =
      call.argument("eventsMaxQueueSize") as? Int
    val pollingInterval =
      call.argument("pollingInterval") as? Long
    val backgroundPollingInterval =
      call.argument("backgroundPollingInterval") as? Long
    val timeoutMillis = call.argument("timeoutMillis") as? Long
    val appVersion = call.argument("appVersion") as? String
    val userAttributes = call.argument("userAttributes") as? Map<String, String> ?: mapOf()
    if (apiKey.isNullOrEmpty()) {
      return fail(result, "apiKey is required")
    }
    if (apiEndpoint.isNullOrEmpty()) {
      return fail(result, "apiEndpoint is required")
    }
    if (featureTag.isNullOrEmpty()) {
      return fail(result, "featureTag is required")
    }
    if (userId.isNullOrEmpty()) {
      return fail(result, "userId is required")
    }
    if (appVersion.isNullOrEmpty()) {
      return fail(result, "appVersion is required")
    }
    try {
      val config: BKTConfig = BKTConfig.builder()
        .apiKey(apiKey)
        .apiEndpoint(apiEndpoint)
        .featureTag(featureTag).let {
          if (eventsFlushInterval != null && eventsFlushInterval > 0) {
            return@let it.eventsFlushInterval(eventsFlushInterval)
          }
          return@let it
        }.let {
          if (eventsMaxQueueSize != null && eventsMaxQueueSize > 0) {
            return@let it.eventsMaxQueueSize(eventsMaxQueueSize)
          }
          return@let it
        }.let {
          if (pollingInterval != null && pollingInterval > 0) {
            return@let it.pollingInterval(pollingInterval)
          }
          return@let it
        }.let {
          if (backgroundPollingInterval != null && backgroundPollingInterval > 0) {
            return@let it.pollingInterval(backgroundPollingInterval)
          }
          return@let it
        }.let {
          if (debugging) {
            return@let it.logger(BucketeerPluginLogger())
          }
          return@let it
        }
        .appVersion(appVersion)
        .build()
      val user: BKTUser = BKTUser.builder()
        .id(userId)
        .customAttributes(userAttributes)
        .build()
      if (timeoutMillis != null) {
        BKTClient.initialize(applicationContext!!, config, user, timeoutMillis)
      } else {
        BKTClient.initialize(applicationContext!!, config, user)
      }
      // Set default EvaluationUpdateListener. It will forward event to the Flutter side for handle
      BKTClient.getInstance().addEvaluationUpdateListener(
        evaluationUpdateListener
      )
      success(result)
    } catch (ex: Exception) {
      fail(result, ex.message)
    }
  }

  private fun currentUser(result: MethodChannel.Result) {
    assertInitialize()
    val user = BKTClient.getInstance().currentUser()
    val map: MutableMap<String, Any> = HashMap()
    map["id"] = user.id
    map["data"] = user.attributes
    success(result, map)
  }

  private fun evaluationDetails(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "featureId is required")
    val evaluation = BKTClient.getInstance().evaluationDetails(featureId)
    if (evaluation == null) {
      fail(result, "Feature flag not found.")
    } else {
      val map: MutableMap<String, Any> = HashMap()
      map["id"] = evaluation.id
      map["featureId"] = evaluation.featureId
      map["featureVersion"] = evaluation.featureVersion
      map["userId"] = evaluation.userId
      map["variationId"] = evaluation.variationId
      map["variationName"] = evaluation.variationName
      map["variationValue"] = evaluation.variationValue
      map["reason"] = evaluation.reason.name
      success(result, map)
    }
  }

  private fun stringVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "featureId is required")
    val defaultValue = args["defaultValue"] as? String
      ?: return fail(result, "defaultValue is required")
    val response = BKTClient.getInstance().stringVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun intVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "featureId is required")
    val defaultValue = args["defaultValue"] as? Int
      ?: return fail(result, "defaultValue is required")
    val response = BKTClient.getInstance().intVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun doubleVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "featureId is required")
    val defaultValue = args["defaultValue"] as? Double
      ?: return fail(result, "defaultValue is required")
    val response = BKTClient.getInstance().doubleVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun boolVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "featureId is required")
    val defaultValue = args["defaultValue"] as? Boolean
      ?: return fail(result, "defaultValue is required")
    val response = BKTClient.getInstance().booleanVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun track(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val goalId = args["goalId"] as? String
      ?: return fail(result, "goalId is required")
    val value = args["value"] as? Double
    if (value != null) {
      BKTClient.getInstance().track(goalId, value)
    } else {
      BKTClient.getInstance().track(goalId)
    }
    success(result)
  }

  private fun jsonVariation(call: MethodCall, result: MethodChannel.Result) {
    try {
      val args = call.arguments<Map<String, Any>>()!!
      val featureId = args["featureId"] as? String
        ?: return fail(result, "featureId is required")
      val defaultValue =
        args["defaultValue"] as? Map<*, *> ?: return fail(result, "defaultValue is required")
      val response =
        BKTClient.getInstance().jsonVariation(featureId, JSONObject(defaultValue))
      val rawJson = response.toMap()
      success(result, rawJson)
    } catch (ex: Exception) {
      fail(result, message = ex.message ?: "Failed to get JSON variation.")
    }
  }

  private fun updateUserAttributes(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments<Map<String, String>>()!!
    BKTClient.getInstance().updateUserAttributes(args)
    success(result)
  }

  private fun fetchEvaluations(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments<Map<String, Any>>()!!
    val timeoutMillis = args["timeoutMillis"] as? Long
    MainScope().launch {
      val err = withContext(Dispatchers.IO) {
        return@withContext BKTClient.getInstance().fetchEvaluations(timeoutMillis).get()
      }
      if (err != null) {
        fail(result, err.message)
      } else {
        success(result)
      }
    }
  }

  private fun flush(result: MethodChannel.Result) {
    MainScope().launch {
      val err = withContext(Dispatchers.IO) {
        return@withContext BKTClient.getInstance().flush().get()
      }
      if (err != null) {
        fail(result, err.message)
      } else {
        success(result)
      }
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      when (CallMethods.values().firstOrNull { call.method.lowercase() == it.name.lowercase() }
        ?: CallMethods.Unknown) {
        CallMethods.Initialize -> {
          initialize(call, result)
        }

        CallMethods.CurrentUser -> {
          currentUser(result)
        }

        CallMethods.EvaluationDetails -> {
          evaluationDetails(call, result)
        }

        CallMethods.StringVariation -> {
          stringVariation(call, result)
        }

        CallMethods.IntVariation -> {
          intVariation(call, result)
        }

        CallMethods.DoubleVariation -> {
          doubleVariation(call, result)
        }

        CallMethods.BoolVariation -> {
          boolVariation(call, result)
        }

        CallMethods.Track -> {
          track(call, result)
        }

        CallMethods.JsonVariation -> {
          jsonVariation(call, result)
        }

        CallMethods.UpdateUserAttributes -> {
          updateUserAttributes(call, result)
        }

        CallMethods.FetchEvaluations -> {
          fetchEvaluations(call, result)
        }

        CallMethods.Flush -> {
          flush(result)
        }

        CallMethods.AddEvaluationUpdateListener,
        CallMethods.RemoveEvaluationUpdateListener,
        CallMethods.ClearEvaluationUpdateListeners -> {
          // note: we will forward all `evaluation update` event to Flutter using
          // event_channel : https://api.flutter.dev/flutter/services/EventChannel-class.html
          // so there is no native code for implement here
          // We will create an default listener for Flutter. See > BucketeerPluginEvaluationUpdateListener.kt
          result.notImplemented()
        }

        CallMethods.Destroy -> {
          BKTClient.destroy()
          success(result)
        }

        CallMethods.Unknown -> {
          result.notImplemented()
        }

      }
    } catch (e: BKTException) {
      fail(result, e.message)
    } catch (e: RuntimeException) {
      fail(result, e.message)
    }
  }

  @Throws(IllegalStateException::class)
  private fun assertInitialize() {
    BKTClient.getInstance()
  }

  private fun success(result: MethodChannel.Result?, response: Any? = null) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = true
    map["response"] = response
    result?.success(map)
  }

  private fun fail(result: MethodChannel.Result?, message: String?) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = false
    map["errorMessage"] = message
    result?.success(map)
  }
}

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
  AddEvaluationUpdateListener,
  RemoveEvaluationUpdateListener,
  ClearEvaluationUpdateListeners,
  Destroy,
  Unknown
}

@Throws(JSONException::class)
fun JSONObject.toMap(): Map<String, Any> {
  val map = mutableMapOf<String, Any>()
  val keysItr: Iterator<String> = this.keys()
  while (keysItr.hasNext()) {
    val key = keysItr.next()
    var value: Any = this.get(key)
    when (value) {
      is JSONArray -> value = value.toList()
      is JSONObject -> value = value.toMap()
    }
    map[key] = value
  }
  return map
}

@Throws(JSONException::class)
fun JSONArray.toList(): List<Any> {
  val list = mutableListOf<Any>()
  for (i in 0 until this.length()) {
    var value: Any = this[i]
    when (value) {
      is JSONArray -> value = value.toList()
      is JSONObject -> value = value.toMap()
    }
    list.add(value)
  }
  return list
}