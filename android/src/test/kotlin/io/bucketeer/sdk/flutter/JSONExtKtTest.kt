package io.bucketeer.sdk.flutter

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class JsonConversionTest {

  @Test
  fun `test JSONObject toMap conversion`() {
    val jsonObject = JSONObject()
    jsonObject.put("key1", "value1")
    jsonObject.put("key2", 123)
    val innerJsonObject = JSONObject()
    innerJsonObject.put("innerKey1", true)
    jsonObject.put("key3", innerJsonObject)

    val map = jsonObject.toMap()

    assertEquals("value1", map["key1"])
    assertEquals(123, map["key2"])
    assertTrue(map["key3"] is Map<*, *>)
    assertEquals(true, (map["key3"] as Map<*, *>)["innerKey1"])
  }

  @Test
  fun `test JSONArray toList conversion`() {
    val jsonArray = JSONArray()
    jsonArray.put("value1")
    jsonArray.put(123)
    val innerJsonObject = JSONObject()
    innerJsonObject.put("innerKey1", true)
    jsonArray.put(innerJsonObject)

    val list = jsonArray.toList()

    assertEquals("value1", list[0])
    assertEquals(123, list[1])
    assertTrue(list[2] is Map<*, *>)
    assertEquals(true, (list[2] as Map<*, *>)["innerKey1"])
  }
}
