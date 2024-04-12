<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

[![pub package](https://img.shields.io/pub/v/api_sdk.svg)](https://pub.dev/packages/api_sdk)

## Getting started

This package is used to make requests to an API. It is based on the [http](https://pub.dev/packages/http) package.
Supports the following request types: `GET`, `POST`, `PUT`, `DELETE`.
Types of request bodies supported: `JSON`, `x-www-form-urlencoded`, `fromData`.

Supports platform compilation for:

- [x] Android
- [x] iOS
- [x] Web
- [x] Windows
- [x] Linux

## Using environment variables

- In the api-key.json.tpl file, make a copy and remove the .tpl extension.
- Add the required variables to the api-key.json file.

```bash
# Ejemplo:
{
    "API_URL": "https://example.com",
    "API_URL_PRODUCTION":"example.com",
    "PROTOCOL":"https",
    "DEBUG": true
},
```

## Compilation Method

- If you are using Visual Studio Code, edit the _.vscode/launch.json_ file. If it does not exist, create it with the following content:

```bash
 {
  "version": "0.2.0",
  "configurations": [
      {
          "name": "app",
          "request": "launch",
          "type": "dart",
          "args": ["--dart-define-from-file","api-key.json"]
      },
      {
          "name": "app (profile mode)",
          "request": "launch",
          "type": "dart",
          "flutterMode": "profile",
          "args": ["--dart-define-from-file","api-key.json"]
      },
      {
          "name": "app (release mode)",
          "request": "launch",
          "type": "dart",
          "flutterMode": "release",
          "args": ["--dart-define-from-file","api-key.json"]
      },
    ]
  },
```

- Afterward, you can compile normally with F5 in debug, profile, or release mode.

## Usage

```bash
# If you define the URLs with the https or http prefix, the PROTOCOL environment variable will not be relevant.
{
    "API_URL": "https://example.com",
    "API_URL_PRODUCTION": "https://example.com",
    "PROTOCOL":"https",
    "DEBUG": true
},
```

o

```bash
# If you define the URLs without the prefix, the PROTOCOL environment variable will be relevant.
{
    "API_URL": "localhost:4000"
    "API_URL_PRODUCTION": "localhost:4000"
    "PROTOCOL": "http"
    "DEBUG": true
}
```

> Note 1: `PROTOCOL`: This variable is used to define the connection protocol. By default, it is `https`, but if you wish to change it to `http`, you should modify the value to `http` and add the `API_URL` variable with the connection domain.

> Note 2: `DEBUG`: By default, it is set to `true`, which will always make requests using the `https` protocol. You can also connect to the production domain by setting `DEBUG` to `false` and providing the `API_URL_PRODUCTION` environment variable.

> Note 3: `API_URL` and `API_URL_PRODUCTION`: These variables are used to define the connection domain. If you use a URL with the `https` or `http` prefix, these variables take precedence over the `PROTOCOL` environment variable. If you use the URL `example.com`, the protocol defined in the `PROTOCOL` environment variable will be used.

## Commands for Different Compilation Types:

> Before compiling, make sure that the DEBUG mode is set as desired.
> Before performing different compilations, it is recommended to run the following command:

```sh
flutter clean
flutter pub get
```

#### Compilation in release mode for APK or app bundle:

```sh
flutter build apk --split-per-abi --dart-define-from-file=api-key.json
```

```sh
flutter build appbundle --dart-define-from-file=api-key.json
```

#### Compilation for iOS:

```sh
flutter build ipa --dart-define-from-file=api-key.json
```

Running the following command will generate the .ipa file for uploading to the App Store:

```sh
open ./build/ios/archive/Runner.xcarchive
```

#### Compilation for the web:

```sh
flutter build web --dart-define-from-file=api-key.json
```

Or, if a base-href is required:

```sh
flutter build web --base-href "/" --dart-define-from-file=api-key.json
```

## Contribution

Of course the project is open source, and you can contribute to it [repository link](https://github.com/JuanDavidQuiceno/api_sdk).

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Contributors

<a href="https://github.com/JuanDavidQuiceno/api_sdk/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=JuanDavidQuiceno/api_sdk" />
</a>
