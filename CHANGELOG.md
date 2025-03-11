# Changelog

## [2.1.2](https://github.com/bucketeer-io/flutter-client-sdk/compare/v2.1.1...v2.1.2) (2025-03-11)


### Bug Fixes

* **android:** cache not being updated in the background after initialized ([#25](https://github.com/bucketeer-io/flutter-client-sdk/issues/25)) ([0e78ff5](https://github.com/bucketeer-io/flutter-client-sdk/commit/0e78ff53c5c0fd4ba9dd24742ba0b2f4fecd30e1))

## [2.1.1](https://github.com/bucketeer-io/flutter-client-sdk/compare/v2.1.0...v2.1.1) (2024-11-27)


### Build System

* **deps:** update ios/android sdk to 2.2.1 ([#22](https://github.com/bucketeer-io/flutter-client-sdk/issues/22)) ([82e757a](https://github.com/bucketeer-io/flutter-client-sdk/commit/82e757a5b9902af9909723dc3c13ea9c299940bb))

## [2.1.0](https://github.com/bucketeer-io/flutter-client-sdk/compare/2.0.0...v2.1.0) (2024-09-17)


### Features

* get variation details by variation type ([#19](https://github.com/bucketeer-io/flutter-client-sdk/issues/19)) ([f59d6be](https://github.com/bucketeer-io/flutter-client-sdk/commit/f59d6be91e14d7752fd17538738f7a77f87a0494))


### Build System

* **deps:** update deps using the Flutter version 3.19.2 ([#21](https://github.com/bucketeer-io/flutter-client-sdk/issues/21)) ([743e534](https://github.com/bucketeer-io/flutter-client-sdk/commit/743e534a9bace488dda65e9647281097d8087115))

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
