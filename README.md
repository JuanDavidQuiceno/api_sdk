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

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

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

#

## Metodo de compilación

- Si van a usar Vscode editar el archivo _.vscode/launch.json_ en caso de no existir crearlo con el siguiente contenido:

```bash
 {
  "version": "0.2.0",
  "configurations": [
      {
          "name": "kit-touch-app",
          "request": "launch",
          "type": "dart",
          "args": ["--dart-define-from-file","api-key.json"]
      },
      {
          "name": "kit-touch-app (profile mode)",
          "request": "launch",
          "type": "dart",
          "flutterMode": "profile",
          "args": ["--dart-define-from-file","api-key.json"]
      },
      {
          "name": "kit-touch-app (release mode)",
          "request": "launch",
          "type": "dart",
          "flutterMode": "release",
          "args": ["--dart-define-from-file","api-key.json"]
      },
    ]
  },
```

- Luego podran compilar normalmente con F5 en modo debug, profile o release.

#

#

## Usage

#

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

> Nota 4: `DEBUG`: de forma predeterminada será `true`, lo que hará que las solicitudes siempre se realicen con el protocolo `https`. También puedes conectarte al dominio de producción cambiando `DEBUG` a "false" y proporcionando la variable de entorno `API_URL_PRODUCTION`, siguiendo las recomendaciones de prefijo.

```

<!-- ## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more. -->
```
