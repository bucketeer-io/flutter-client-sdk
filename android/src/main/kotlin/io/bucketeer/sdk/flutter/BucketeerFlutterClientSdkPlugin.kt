package io.bucketeer.sdk.flutter

import android.content.Context
import android.util.Log
import io.bucketeer.sdk.android.BKTClient
import io.bucketeer.sdk.android.BKTConfig
import io.bucketeer.sdk.android.BKTEvaluationDetails
import io.bucketeer.sdk.android.BKTException
import io.bucketeer.sdk.android.BKTUser
import io.bucketeer.sdk.android.BKTValue
import io.bucketeer.sdk.android.internal.evaluation.getBKTValue
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
import org.json.JSONObject
import java.util.concurrent.Future

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
  private var evaluationUpdateListenToken: String? = null
  private val logger = BucketeerPluginLogger()
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

  private fun initialize(call: MethodCall, methodChannelResult: MethodChannel.Result) {
    val debugging = (call.argument("debugging") as? Boolean) ?: false
    val userId = call.argument("userId") as? String
    val apiKey = call.argument("apiKey") as? String
    val apiEndpoint = call.argument("apiEndpoint") as? String
    val featureTag = (call.argument("featureTag") as? String) ?: ""
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
      return failWithIllegalArgumentException(methodChannelResult, "apiKey is required")
    }
    if (apiEndpoint.isNullOrEmpty()) {
      return failWithIllegalArgumentException(methodChannelResult, "apiEndpoint is required")
    }
    if (userId.isNullOrEmpty()) {
      return failWithIllegalArgumentException(methodChannelResult, "userId is required")
    }
    if (appVersion.isNullOrEmpty()) {
      return failWithIllegalArgumentException(methodChannelResult, "appVersion is required")
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
            return@let it.logger(logger)
          }
          return@let it
        }
        .appVersion(appVersion)
        .build()
      val user: BKTUser = BKTUser.builder()
        .id(userId)
        .customAttributes(userAttributes)
        .build()

      val future: Future<BKTException?> = if (timeoutMillis != null) {
        BKTClient.initialize(applicationContext!!, config, user, timeoutMillis)
      } else {
        BKTClient.initialize(applicationContext!!, config, user)
      }

      MainScope().launch {
        val initializeResult = withContext(Dispatchers.IO) {
          future.get()
        }
        when (initializeResult) {
          is BKTException.TimeoutException -> {
            logger.log(Log.WARN, {
              "Fetch evaluations failed during the initialize process. It will try to fetch again in the next polling."
            }, initializeResult)
            fail(methodChannelResult, initializeResult.message, exception = initializeResult)
          }
          null -> {
            success(methodChannelResult)
          }
          else -> fail(methodChannelResult, initializeResult.message, exception = initializeResult)
        }
      }
    } catch (ex: Exception) {
      logger.log(Log.ERROR, {
        "Failed to initialize the BKTClient. Error: ${ex}}"
      }, ex)
      fail(methodChannelResult, ex.message, exception = ex)
    }
  }

  private fun registerProxyEvaluationUpdateListener(): String {
    return BKTClient.getInstance().addEvaluationUpdateListener(
      evaluationUpdateListener
    )
  }

  private fun currentUser(result: MethodChannel.Result) {
    val user = BKTClient.getInstance().currentUser()
    val map: MutableMap<String, Any> = HashMap()
    map["id"] = user.id
    map["data"] = user.attributes
    success(result, map)
  }

  @Deprecated(
    message =
    "evaluationDetails() is deprecated",
  )
  private fun evaluationDetails(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return failWithIllegalArgumentException(result, "featureId is required")
    val evaluation = BKTClient.getInstance().evaluationDetails(featureId)
    if (evaluation == null) {
      val ex = BKTException.FeatureNotFoundException(message = "Feature flag not found")
      fail(result, ex.message, exception = ex)
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
    val requestContext = requiredVariationContext<String>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().stringVariation(requestContext.featureId, requestContext.defaultValue)
      success(result, response)
    }
  }

  private fun stringVariationDetails(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<String>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().stringVariationDetails(requestContext.featureId, requestContext.defaultValue)
      success(result, response.toMap())
    }
  }

  private fun intVariation(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Int>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().intVariation(requestContext.featureId, requestContext.defaultValue)
      success(result, response)
    }
  }

  private fun intVariationDetails(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Int>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().intVariationDetails(requestContext.featureId, requestContext.defaultValue)
      success(result, response.toMap())
    }
  }

  private fun doubleVariation(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Double>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().doubleVariation(requestContext.featureId, requestContext.defaultValue)
      success(result, response)
    }
  }

  private fun doubleVariationDetails(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Double>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().doubleVariationDetails(requestContext.featureId, requestContext.defaultValue)
      success(result, response.toMap())
    }
  }

  private fun boolVariation(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Boolean>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().booleanVariation(requestContext.featureId, requestContext.defaultValue)
      success(result, response)
    }
  }

  private fun boolVariationDetails(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<Boolean>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().boolVariationDetails(requestContext.featureId, requestContext.defaultValue)
      success(result, response.toMap())
    }
  }

  private fun objectVariation(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<String>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().objectVariation(requestContext.featureId, requestContext.defaultValue.getBKTValue())
      success(result, response)
    }
  }

  private fun objectVariationDetails(call: MethodCall, result: MethodChannel.Result) {
    val requestContext = requiredVariationContext<String>(call, result)
    requestContext?.let {
      val response = BKTClient.getInstance().objectVariationDetails(requestContext.featureId, requestContext.defaultValue.getBKTValue())
      success(result, response.toMap())
    }
  }

  @Deprecated(
    message =
    "jsonVariation() is deprecated",
  )
  private fun jsonVariation(call: MethodCall, result: MethodChannel.Result) {
    try {
      val requestContext = requiredVariationContext<Map<*, *>>(call, result)
      requestContext?.let {
        val response =
          BKTClient.getInstance().jsonVariation(requestContext.featureId, JSONObject(requestContext.defaultValue))
        val rawJson = response.toMap()
        success(result, rawJson)
      }
    } catch (ex: Exception) {
      fail(result, message = ex.message ?: "Failed to get JSON variation.", exception = ex)
    }
  }

  private fun track(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments<Map<String, Any>>()!!
    val goalId = args["goalId"] as? String
      ?: return failWithIllegalArgumentException(result, "goalId is required")
    val value = args["value"] as? Double
    if (value != null) {
      BKTClient.getInstance().track(goalId, value)
    } else {
      BKTClient.getInstance().track(goalId)
    }
    success(result)
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
        try {
          return@withContext BKTClient.getInstance().fetchEvaluations(timeoutMillis).get()
        } catch (ex: Exception) {
          return@withContext ex
        }
      }
      if (err != null) {
        fail(result, err.message, exception = err)
      } else {
        success(result)
      }
    }
  }

  private fun flush(result: MethodChannel.Result) {
    MainScope().launch {
      val err = withContext(Dispatchers.IO) {
        try {
          return@withContext BKTClient.getInstance().flush().get()
        } catch (ex: Exception) {
          return@withContext ex
        }
      }
      if (err != null) {
        fail(result, err.message, exception = err)
      } else {
        success(result)
      }
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      val callMethod = CallMethods.entries.firstOrNull { call.method.lowercase() == it.name.lowercase() }
        ?: CallMethods.Unknown

      if (CallMethods.shouldAssertInitialize(callMethod)) {
        // make sure the client has been initialize
        assertInitialize()
      }

      when (callMethod) {
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

        CallMethods.StringVariationDetails -> {
          stringVariationDetails(call, result)
        }

        CallMethods.IntVariation -> {
          intVariation(call, result)
        }

        CallMethods.IntVariationDetails -> {
          intVariationDetails(call, result)
        }

        CallMethods.DoubleVariation -> {
          doubleVariation(call, result)
        }

        CallMethods.DoubleVariationDetails -> {
          doubleVariationDetails(call, result)
        }

        CallMethods.BoolVariation -> {
          boolVariation(call, result)
        }

        CallMethods.BoolVariationDetails -> {
          boolVariationDetails(call, result)
        }

        CallMethods.ObjectVariation -> {
          objectVariation(call, result)
        }

        CallMethods.ObjectVariationDetails -> {
          objectVariationDetails(call, result)
        }

        CallMethods.JsonVariation -> {
          jsonVariation(call, result)
        }

        CallMethods.Track -> {
          track(call, result)
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

        // The SDK creates a default listener. See > BucketeerPluginEvaluationUpdateListener.kt
        // Note: The SDK will forward all the `evaluation update` events to Flutter using `event_channel`
        // https://api.flutter.dev/flutter/services/EventChannel-class.html
        CallMethods.AddProxyEvaluationUpdateListener -> {
          // Register the proxy listener if needed
          var listenToken = evaluationUpdateListenToken
          if (listenToken == null) {
            listenToken = registerProxyEvaluationUpdateListener()
            evaluationUpdateListenToken = listenToken
          }
          success(result, listenToken)
        }

        CallMethods.Destroy -> {
          val listenToken = evaluationUpdateListenToken
          if (listenToken != null) {
            BKTClient.getInstance().removeEvaluationUpdateListener(listenToken)
            evaluationUpdateListenToken = null
          }
          BKTClient.destroy()
          success(result)
        }

        CallMethods.Unknown -> {
          result.notImplemented()
        }

      }
    } catch (e: Exception) {
      fail(result, e.message, exception = e)
    }
  }

  @Throws(BKTException.IllegalStateException::class)
  private fun assertInitialize() {
    try {
      BKTClient.getInstance()
    } catch (ex: BKTException.IllegalStateException) {
      throw  ex
    } catch (ex: Exception) {
      throw  BKTException.IllegalStateException(message =  ex.message ?: "")
    }
  }

  private fun success(result: MethodChannel.Result?, response: Any? = null) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = true
    map["response"] = response
    result?.success(map)
  }

  private fun failWithIllegalArgumentException(result: MethodChannel.Result?, message: String) {
    val ex = BKTException.IllegalArgumentException(message = message)
    fail(result = result, message = ex.message, exception = ex)
  }

  private fun fail(result: MethodChannel.Result?, message: String?, exception: Exception?) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = false
    map["errorMessage"] = message
    map["errorCode"] = exception?.toErrorCode() ?: 0
    result?.success(map)
  }

  private inline fun <reified T> requiredVariationContext(call: MethodCall, result: MethodChannel.Result): VariationRequestContext<T>? {
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
    if (featureId == null) {
      failWithIllegalArgumentException(result, "featureId is required")
      return null
    }
    val defaultValue = args["defaultValue"]
    if (defaultValue is T) {
      return VariationRequestContext(featureId, defaultValue)
    }
    failWithIllegalArgumentException(result, "defaultValue is required")
    return null
  }
}

class VariationRequestContext<T>(
  val featureId: String,
  val defaultValue: T
)

inline fun <reified T : Any> BKTEvaluationDetails<T>.toMap(): Map<String, Any> {
  val map: MutableMap<String, Any> = HashMap()
  val evaluation = this
  map["featureId"] = evaluation.featureId
  map["featureVersion"] = evaluation.featureVersion
  map["userId"] = evaluation.userId
  map["variationId"] = evaluation.variationId
  map["variationName"] = evaluation.variationName
  if (evaluation.variationValue is BKTValue) {
    map["variationValue"] = (evaluation.variationValue as BKTValue).toRawData()
  } else {
    map["variationValue"] = evaluation.variationValue
  }
  map["reason"] = evaluation.reason.name
  return map
}

fun BKTValue.toRawData(): Any = when (this) {
  is BKTValue.String -> this.string
  is BKTValue.Boolean -> this.boolean
  is BKTValue.Number -> this.number
  is BKTValue.Structure -> this.structure.mapValues { it.value.toRawData() }
  is BKTValue.List -> this.list.map { it.toRawData() }
  BKTValue.Null -> "null"
}