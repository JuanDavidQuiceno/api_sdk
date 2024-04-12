library api_sdk;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

/// cast a variable to a type
T? cast<T>(x) => x is T ? x : null;

/// The protocol of the endpoint
///
/// [Protocol.http], [Protocol.https], the default is [Protocol.https]
enum Protocol { http, https }

/// The method of the endpoint
///
/// [Method.get], [Method.post], [Method.put], [Method.delete]
enum Method { get, post, put, delete }

/// The body type of the endpoint
///
/// [BodyType.raw], [BodyType.formData], [BodyType.xWwwformurlencoded], the default is [BodyType.raw]
enum BodyType { raw, formData, xWwwformurlencoded }

/// The endpoint class to extend
abstract class EndpointConfig {
  // si se require cambiar la url del api que se asigna en las variables de entorno
  String setBaseUrl = '';

  String get path;

  Method get method;

  BodyType get bodyType => BodyType.raw;

  Map<String, dynamic> queryParameters = {};

  Map<String, String> headers = {};

  Map<String, dynamic> body = {};

  List<ImagesModelEndpoint> files = [];

  EndpointConfig();
}

/// The response of the endpoint
///
/// [ResponseApiSdk] is the response of the endpoint
class ResponseApiSdk {
  /// The body of the response
  dynamic body;

  /// the headers of the response
  Map<String, String>? headers;

  /// The status code of the response
  int statusCode;

  ResponseApiSdk({
    required this.body,
    required this.statusCode,
    this.headers = const {},
  });

  factory ResponseApiSdk.fromJson(Map<String, dynamic> json) => ResponseApiSdk(
        statusCode: json['statusCode'] == null
            ? 500
            : int.tryParse(json['statusCode'].toString()) ?? 500,
        headers: json['headers'] == null
            ? {}
            : cast<Map<String, String>>(json['headers']),
        body: json['body'] == null
            ? null
            : cast<Map<String, dynamic>>(json['body']),
      );

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'headers': headers,
        'body': body,
      };
}

/// The file of the endpoint
///
/// [ImagesModelEndpoint] is the file of the endpoint
class ImagesModelEndpoint {
  String path;
  String key;
  String? url;
  MediaType? contentType;

  ImagesModelEndpoint({
    required this.path,
    required this.key,
    this.url,
    this.contentType,
  });

  factory ImagesModelEndpoint.fromJson(Map<String, dynamic> json) =>
      ImagesModelEndpoint(
        path: json['path'] == null ? '' : json['path'].toString(),
        key: json['key'] == null ? 'files' : json['key'].toString(),
        url: json['url'],
        contentType: json['contentType'] == null
            ? null
            : MediaType.parse(json['contentType'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'key': key,
        'url': url,
        'contentType': contentType?.toString(),
      };
}

/// The repository of the endpoint
///
/// [ApiSdkRepository] is the repository of the endpoint
abstract class ApiSdkRepository {
  Future<ResponseApiSdk> run({required EndpointConfig endpoint});
}

/// The repository of the endpoint
///
/// [ApiSdk] is the repository of the endpoint
class ApiSdk implements ApiSdkRepository {
  final _logger = Logger();
  final debug = const String.fromEnvironment('DEBUG').isNotEmpty
      ? const String.fromEnvironment('DEBUG').toString().toLowerCase() == 'true'
          ? true
          : false
      : kDebugMode;

  @override
  Future<ResponseApiSdk> run({required EndpointConfig endpoint}) async {
    Uri url;
    try {
      url = _FormatUrl().define(endpoint: endpoint);
    } catch (e) {
      if (debug) _logger.e('APIRepository - Error parse uri$e ');
      throw Exception('Error parse uri $e');
    }
    // definimos el tipo de body
    switch (endpoint.bodyType) {
      case BodyType.formData:
        return _formData(url: url, endpoint: endpoint);
      case BodyType.xWwwformurlencoded:
        return _xWwwformurlencoded(url: url, endpoint: endpoint);
      default:
        return _raw(url: url, endpoint: endpoint);
    }
  }

  Future<ResponseApiSdk> _formData(
      {required Uri url, required EndpointConfig endpoint}) async {
    try {
      var request = http.MultipartRequest(
          endpoint.method.name.toString().toUpperCase(), url);
      // headers from request form-data
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: '*/*',
      });
      request.headers.addAll(endpoint.headers);

      Map<String, String> body = {};
      endpoint.body.forEach((key, value) {
        body.addAll({key: value.toString()});
      });

      /// add body to request
      request.fields.addAll(body);

      /// verify if exist files
      if (endpoint.files.isNotEmpty) {
        for (ImagesModelEndpoint element in endpoint.files) {
          /// verify

          request.files.add(
            MultipartFile.fromBytes(
              element.key,
              await File.fromUri(Uri.parse(element.path)).readAsBytes(),
              filename: element.path,
              contentType: element.contentType,
            ),
          );
        }
      }
      if (debug) {
        _logger.d(
            'Type: form-data - ${endpoint.method.name}() with url ($url) - headers (${request.headers}) - body (${request.fields}) - files ${endpoint.files.map((e) => e.toJson())}');
      }
      http.StreamedResponse response = await request.send();

      String data = await response.stream.bytesToString();
      final decodedBody = json.decode(data);
      return _responseMap(
        headers: response.headers,
        statusCode: response.statusCode,
        body: decodedBody,
      );
    } catch (e) {
      if (debug) {
        _logger.d('catch request form-data: $e');
      }
      throw Exception('Error send request form-data $e');
    }
  }

  Future<ResponseApiSdk> _xWwwformurlencoded(
      {required Uri url, required EndpointConfig endpoint}) async {
    try {
      var request =
          http.Request(endpoint.method.name.toString().toUpperCase(), url);
      // headers from request x-www-form-urlencoded
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        HttpHeaders.acceptHeader: '*/*',
      });
      request.headers.addAll(endpoint.headers);
      Map<String, String> body = {};
      endpoint.body.forEach((key, value) {
        body.addAll({key: value.toString()});
      });
      // agregamos los de texto a las al body
      request.bodyFields = body;
      if (debug) {
        _logger.d(
            'Type: x-www-form-urlencoded - ${endpoint.method.name}() with url ($url) - headers (${request.headers}) - body (${request.bodyFields})');
      }
      http.StreamedResponse response = await request.send();

      final decodedBody = json.decode(await response.stream.bytesToString());
      return _responseMap(
        headers: response.headers,
        statusCode: response.statusCode,
        body: decodedBody,
      );
    } catch (e) {
      if (debug) {
        _logger.d('catch $e');
      }
      throw Exception('Error send request x-www-form-urlencoded $e');
    }
  }

  Future<ResponseApiSdk> _raw(
      {required Uri url, required EndpointConfig endpoint}) async {
    try {
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: '*/*',
      };
      headers.addAll(endpoint.headers);

      switch (endpoint.method) {
        case Method.get:
          return _get(url, headers).then(_handleResponse);
        case Method.post:
          return _post(url, headers, endpoint.body).then(_handleResponse);
        case Method.put:
          return _put(url, headers, endpoint.body).then(_handleResponse);
        case Method.delete:
          return _delete(url, headers, endpoint.body).then(_handleResponse);
      }
    } catch (e) {
      if (debug) _logger.e('APIRepository - Error send request $e ');
      throw Exception('Error send request raw Error parse uri $e');
    }
  }

  Future<Response> _get(Uri url, Map<String, String> headers) {
    if (debug) {
      _logger.d('Type: raw - get() with url ($url) - headers ($headers)');
    }
    return http.get(url, headers: headers);
  }

  Future<Response> _post(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    if (debug) {
      _logger.d(
          'Type: raw - post() with url ($url) - headers ($headers) - body ($body)');
    }
    return http.post(url, headers: headers, body: json.encode(body));
  }

  Future<Response> _put(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    if (debug) {
      _logger.d(
          'Type: raw - put() with url ($url) - headers ($headers) - body ($body)');
    }
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<Response> _delete(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    if (debug) {
      _logger.d(
          'Type: raw - delete() with url ($url) - headers ($headers) - body ($body)');
    }
    return http.delete(url, headers: headers, body: jsonEncode(body));
  }

  ResponseApiSdk _handleResponse(Response response) {
    if (response.body.isEmpty) {
      return _responseMap(
        statusCode: response.statusCode,
        headers: response.headers,
        body: {},
      );
    }

    final decodedBody = json.decode(response.body);
    // validar si el body es un map una lista o un string

    return _responseMap(
      statusCode: response.statusCode,
      headers: response.headers,
      body: decodedBody,
    );
  }

  ResponseApiSdk _responseMap({
    Map<String, String>? headers,
    dynamic body,
    int? statusCode = 500,
  }) {
    if (debug) {
      _logger.d('Response - status code: $statusCode - body: $body');
    }
    if (body is Map<String, dynamic>) {
      return ResponseApiSdk(
        statusCode: statusCode ?? 500,
        headers: headers,
        body: body,
      );
    }

    return ResponseApiSdk(
      statusCode: statusCode!,
      headers: headers,
      body: body.isNotEmpty ? {'data': body} : null,
    );
  }
}

/// The format url of the endpoint
///
/// [_FormatUrl] is the format url of the endpoint, this class is used to format the url of the endpoint
class _FormatUrl {
  Uri define({required EndpointConfig endpoint}) {
    Protocol protocolo = const String.fromEnvironment('PROTOCOL').isNotEmpty &&
            const String.fromEnvironment('PROTOCOL').toString().toLowerCase() ==
                'http'
        ? Protocol.http
        : Protocol.https;

    // definimos el url de las variables de entorno
    String apiUrl = const String.fromEnvironment('API_URL');

    //asignamos el path endpoint.path y eliminamos el primer / en caso de que lo tenga
    String path = endpoint.path.startsWith('/')
        ? endpoint.path.substring(1)
        : endpoint.path;

    // si se usa la url diferente a las de environment
    if (endpoint.setBaseUrl.isNotEmpty) {
      // validar si la setApiUrl contiene http o https=
      if (endpoint.setBaseUrl.contains('http://')) {
        return _http(
            apiUrl: endpoint.setBaseUrl,
            path: path,
            queryParameters: endpoint.queryParameters);
      } else {
        return _https(
            apiUrl: endpoint.setBaseUrl,
            path: path,
            queryParameters: endpoint.queryParameters);
      }
    } else if (protocolo == Protocol.https || apiUrl.contains('https://')) {
      return _https(
          apiUrl: apiUrl,
          path: path,
          queryParameters: endpoint.queryParameters);
    } else {
      return _http(
          apiUrl: apiUrl,
          path: path,
          queryParameters: endpoint.queryParameters);
    }
  }

  Uri _https(
      {required String apiUrl,
      required String path,
      required Map<String, dynamic> queryParameters}) {
    return Uri.https(
      apiUrl.replaceAll('https://', ''),
      path,
      queryParameters,
    );
  }

  Uri _http(
      {required String apiUrl,
      required String path,
      required Map<String, dynamic> queryParameters}) {
    return Uri.http(
      apiUrl.replaceAll('http://', ''),
      path,
      queryParameters,
    );
  }
}
