# Changelog

## 2.0.0 (2024-04-09)

This version brings the **BREAKING CHANGES**.

- Removed the gRPC dependency (Response time was improved by **50% faster**)
- Improved SDK metrics
- Changed SDK initialization process
- Changed the get variation interfaces (`booleanVariation`, `stringVariation`, etc.)
- Added `flush` interface to manually send events in the DB to the server if needed
- Added `addEvaluationUpdateListener` interface so the user can listen when the evaluations change in the DB
- Added background polling (The SDK will continue polling the latest data from the server even if in the background)
- Now the SDK flushes events when the app enters the background

See [the documentation](https://docs.bucketeer.io/sdk/client-side/flutter) for the 2.0.0 version.

### Features

* initial implementation ([#2](https://github.com/bucketeer-io/flutter-client-sdk/issues/2)) ([63954e9](https://github.com/bucketeer-io/flutter-client-sdk/commit/63954e9584c1c929258541b3f63e781df0440ff5))
