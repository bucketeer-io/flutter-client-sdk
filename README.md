<p align="left">
  <a href="https://pub.dartlang.org/packages/bucketeer_flutter_client_sdk">
    <img src="https://img.shields.io/pub/v/bucketeer_flutter_client_sdk.svg">
  </a>
</p>

# Bucketeer Client-side SDK for Flutter

[Bucketeer](https://bucketeer.io) is an open-source platform created by [CyberAgent](https://www.cyberagent.co.jp/en) to help teams make better decisions, reduce deployment lead time and release risk through feature flags. Bucketeer offers advanced features like dark launches and staged rollouts that perform limited releases based on user attributes, devices, and other segments.

[Getting started](https://docs.bucketeer.io/sdk/client-side/flutter) using Bucketeer SDK.

## Installation

See our [documentation](https://docs.bucketeer.io/sdk/client-side/flutter) to install the SDK.

## Contributing

We would ❤️ for you to contribute to Bucketeer and help improve it! Anyone can use and enjoy it!

Please follow our contribution guide [here](https://docs.bucketeer.io/contribution-guide/).

## Development

### Setup

```sh
make setup
```

### Install the dependencies

```sh
make deps
```

### Build

#### Build SDK for Android

```sh
make build-android
```

#### Build SDK for iOS

```sh
make build-ios
```

### Tests

#### Unit test

```sh
make unit-test
```

#### E2E

To run the E2E test, set the following environment variables before running it.

- E2E_API_ENDPOINT
- E2E_API_KEY

```sh
make e2e BKT_API_KEY=<API_KEY> BKT_API_ENDPOINT=<API_ENDPOINT>
```

### Other commands

For other commands, please take a look at the [Makefile](https://github.com/bucketeer-io/flutter-client-sdk/blob/main/Makefile).

## License

Apache License 2.0, see [LICENSE](https://github.com/bucketeer-io/ios-client-sdk/blob/main/LICENSE).
