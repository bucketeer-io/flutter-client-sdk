# Changelog

## [2.2.0](https://github.com/bucketeer-io/flutter-client-sdk/compare/v2.1.2...v2.2.0) (2026-05-11)

### Features

- update wrapper SDK's sourceId and version ([#31](https://github.com/bucketeer-io/flutter-client-sdk/issues/31)) ([ed5a914](https://github.com/bucketeer-io/flutter-client-sdk/commit/ed5a9147109da3106fc19b11dd1517b878f6f35e))

### Build System

- **deps:** update iOS SDK to [v2.3.0](https://github.com/bucketeer-io/ios-client-sdk/releases/tag/v2.3.0) and Android SDK to [v2.3.1](https://github.com/bucketeer-io/android-client-sdk/releases/tag/v2.3.1) ([ed5a914](https://github.com/bucketeer-io/flutter-client-sdk/commit/ed5a9147109da3106fc19b11dd1517b878f6f35e))

### Native SDK Changes

This release also brings the following changes from the underlying native SDKs.

#### iOS SDK ([v2.2.1...v2.3.0](https://github.com/bucketeer-io/ios-client-sdk/compare/v2.2.1...v2.3.0))

##### Features

- add detailed reason error types ([ios-client-sdk#100](https://github.com/bucketeer-io/ios-client-sdk/issues/100))
- auto retry on deployment-related 499 errors ([ios-client-sdk#114](https://github.com/bucketeer-io/ios-client-sdk/issues/114))
- thread-safe user attribute update tracking and safe reading/updating of evaluations ([ios-client-sdk#116](https://github.com/bucketeer-io/ios-client-sdk/issues/116))

##### Bug Fixes

- initialization request cancelled by poller on slow network ([ios-client-sdk#118](https://github.com/bucketeer-io/ios-client-sdk/issues/118))

##### Miscellaneous

- allow to set wrapper SDK info (sourceId & version) ([ios-client-sdk#115](https://github.com/bucketeer-io/ios-client-sdk/issues/115))

##### Build System

- update the minimum deployment target version to 12.0 ([ios-client-sdk#110](https://github.com/bucketeer-io/ios-client-sdk/issues/110))

#### Android SDK ([v2.2.1...v2.3.1](https://github.com/bucketeer-io/android-client-sdk/compare/v2.2.1...v2.3.1))

##### Features

- add detailed reason error types ([android-client-sdk#241](https://github.com/bucketeer-io/android-client-sdk/issues/241))
- auto retry on deployment-related 499 errors ([android-client-sdk#240](https://github.com/bucketeer-io/android-client-sdk/issues/240))
- thread-safe for user attribute update tracking and safe reading/updating for evaluations ([android-client-sdk#242](https://github.com/bucketeer-io/android-client-sdk/issues/242))

##### Bug Fixes

- measure latencySecond with monotonic high-resolution clock ([android-client-sdk#250](https://github.com/bucketeer-io/android-client-sdk/issues/250))
- missing request read and write timeout settings ([android-client-sdk#237](https://github.com/bucketeer-io/android-client-sdk/issues/237))
- e2e fail because userAttributesUpdated should be bool ([android-client-sdk#230](https://github.com/bucketeer-io/android-client-sdk/issues/230))
- prevent logger leaks when destroying and not working when building the client ([android-client-sdk#227](https://github.com/bucketeer-io/android-client-sdk/issues/227))
- wrapperSdkVersion is required when setting wrapperSdkSourceId ([android-client-sdk#231](https://github.com/bucketeer-io/android-client-sdk/issues/231))
- concurrentModificationException when sending evaluation update events ([android-client-sdk#219](https://github.com/bucketeer-io/android-client-sdk/issues/219))

##### Miscellaneous

- allow setting the wrapper sdk version & source id for open feature support ([android-client-sdk#226](https://github.com/bucketeer-io/android-client-sdk/issues/226))

##### Build System

- **deps:** downgrade kotlin to 2.0.21 for app compatibility ([android-client-sdk#223](https://github.com/bucketeer-io/android-client-sdk/issues/223))

## [2.1.2](https://github.com/bucketeer-io/flutter-client-sdk/compare/v2.1.1...v2.1.2) (2025-03-11)

### Bug Fixes

- **android:** cache not being updated in the background after initialized ([#25](https://github.com/bucketeer-io/flutter-client-sdk/issues/25)) ([0e78ff5](https://github.com/bucketeer-io/flutter-client-sdk/commit/0e78ff53c5c0fd4ba9dd24742ba0b2f4fecd30e1))

## [2.1.1](https://github.com/bucketeer-io/flutter-client-sdk/compare/v2.1.0...v2.1.1) (2024-11-27)

### Build System

- **deps:** update ios/android sdk to 2.2.1 ([#22](https://github.com/bucketeer-io/flutter-client-sdk/issues/22)) ([82e757a](https://github.com/bucketeer-io/flutter-client-sdk/commit/82e757a5b9902af9909723dc3c13ea9c299940bb))

## [2.1.0](https://github.com/bucketeer-io/flutter-client-sdk/compare/2.0.0...v2.1.0) (2024-09-17)

### Features

- get variation details by variation type ([#19](https://github.com/bucketeer-io/flutter-client-sdk/issues/19)) ([f59d6be](https://github.com/bucketeer-io/flutter-client-sdk/commit/f59d6be91e14d7752fd17538738f7a77f87a0494))

### Build System

- **deps:** update deps using the Flutter version 3.19.2 ([#21](https://github.com/bucketeer-io/flutter-client-sdk/issues/21)) ([743e534](https://github.com/bucketeer-io/flutter-client-sdk/commit/743e534a9bace488dda65e9647281097d8087115))

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

- initial implementation ([#2](https://github.com/bucketeer-io/flutter-client-sdk/issues/2)) ([63954e9](https://github.com/bucketeer-io/flutter-client-sdk/commit/63954e9584c1c929258541b3f63e781df0440ff5))
