abstract class Constants {
  // Configuring apps with compilation environment declarations
  // https://dart.dev/guides/environment-declarations
  static const apiKey = String.fromEnvironment("API_KEY", defaultValue: "*****************************");
  static const apiEndpoint = String.fromEnvironment("API_ENDPOINT", defaultValue:"https://api.example.com");
  static const exampleFeatureTag = "ios";
  static const exampleUserId = "bucketeer-ios-user-id-1";
  static const exampleEventsFlushInterval =  60000;
  static const exampleEventMaxQueueSize = 4;
  static const examplePollingInterval = 60000;
  static const exampleBackgroundPollingInterval = 1200000;
}