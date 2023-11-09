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

## Getting started

- En el archivo api-key.json.tpl dupliquelo y elimine .tpl
- Agregar las variables requeridas en el archivo api-key.json

```bash
# Ejemplo:
{
    "API_URL": "https://example.com",
    "API_URL_PRODUCTION":"example.com",
    "PROTOCOL":"https",
    "DEBUG": true
},
```

## Metodo de compilación

- Si van a usar Vscode editar el archivo _.vscode/launch.json_ en caso de no existir crearlo con el siguiente contenido:

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

- Luego podran compilar normalmente con F5 en modo debug, profile o release.

## Usage

```bash
# Si se definen las url con el prefijo https o http la variable de entorno PROTOCOL no tendra relevancia.
{
    "API_URL": "https://example.com",
    "API_URL_PRODUCTION": "https://example.com",
    "PROTOCOL":"https",
    "DEBUG": true
},
```

o

```bash
# Si se definen las url sin el prefijo la variable de entorno PROTOCOL tendra relevancia.
{
    "API_URL": "localhost:4000"
    "API_URL_PRODUCTION": "localhost:4000"
    "PROTOCOL": "http"
    "DEBUG": true
}
```

> Note 1: `PROTOCOL`: Esta variable es para definir el protocolo de conexión, por defecto es `https`, pero si se desea cambiar a `http` se debe cambiar el valor a `http` y agregar la variable `API_URL` con el dominio de conexión.

> Note 2: `DEBUG`: por defecto sera `true`, lo cual siempre hara las peticiones con protocolo `https`, Tambien se puede conectar al dominio de producción cambiando `DEBUG` a "false" y proporcionando la variable de entorno `API_URL_PRODUCTION`.

> Nota 3: `API_URL` y `API_URL_PRODUCTION`: Esta variable es para definir el dominio de conexión , si usas la url con el prefijo `https` o `http` este tendra relevancia por encima de la variable de entorno `PROTOCOL`, en caso de usar la url `example.com` se usara el protocolo definido en la variable de entorno `PROTOCOL`.

## Comando para los diferentes tipos de compilaciones:

> Antes de compilar verifique que el modo de `DEBUG` sea el deseado.
> Antes de hacer las diferentes compilaciones se recomienda ejecutar el comando

```sh
flutter clean
flutter pub get
```

Compilación modo release para apk o appbundle:

```sh
flutter build apk --split-per-abi --dart-define-from-file=api-key.json
```

```sh
flutter build appbundle --dart-define-from-file=api-key.json
```

Compilación para ios:

```sh
flutter build ipa --dart-define-from-file=api-key.json
```

ejectutando el siguiente comando se obtendra el archivo .ipa para subir a la appstore

```sh
open ./build/ios/archive/Runner.xcarchive
```

Compilación para web:

```sh
flutter build web --dart-define-from-file=api-key.json
```

o en caso de que se requiera un base-href

```sh
flutter build web --base-href "/" --dart-define-from-file=api-key.json
```

## Contribution

Of course the project is open source, and you can contribute to it [repository link](https://github.com/koukibadr/Elegant-Notification)

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Contributors

<a href="https://github.com/JuanDavidQuiceno/api_sdk/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=JuanDavidQuiceno/api_sdk" />
</a>
