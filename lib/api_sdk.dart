library api_sdk;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

// /// A Calculator.
// class Calculator {
//   /// Returns [value] plus 1.
//   int addOne(int value) => value + 1;
// }
T? cast<T>(x) => x is T ? x : null;

enum Protocol { http, https }

enum Method { get, post, put, delete }

abstract class Endpoint {
  // si se require cambiar la url del api que se asigna en las variables de entorno
  String setApiUrl = '';

  String get path;

  Method get method;

  Map<String, dynamic> queryParameters = {};

  Map<String, String> headers = {};

  Map<String, dynamic> body = {};

  List<ImagesModelEndpoint> files = [];

  Endpoint();
}

class ImagesModelEndpoint {
  String path;
  String key;
  String? url;

  ImagesModelEndpoint({
    required this.path,
    required this.key,
    this.url,
  });

  factory ImagesModelEndpoint.fromJson(Map<String, dynamic> json) =>
      ImagesModelEndpoint(
        path: json['path'] == null ? '' : json['path'].toString(),
        key: json['key'] == null ? 'files' : json['key'].toString(),
        url: json['url'],
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'key': key,
        'url': url,
      };
}

abstract class ApiSdkRepository {
  Future<Map<String, dynamic>> raw(
      {String? setApiUrl, required Endpoint endpoint});
  Future<Map<String, dynamic>> formData(
      {String? setApiUrl, required Endpoint endpoint});
  Future<Map<String, dynamic>> xWwwformurlencoded(
      {String? setApiUrl, required Endpoint endpoint});
}

class ApiSdk implements ApiSdkRepository {
  final _logger = Logger();

  @override
  Future<Map<String, dynamic>> raw(
      {required Endpoint endpoint, String? setApiUrl}) async {
    _logger.d('Request endpoint: ${endpoint.body}');
    Uri url;
    try {
      url = _defineUrl(endpoint: endpoint);
    } catch (e) {
      _logger.e('APIRepository - Error parse uri$e ');
      Exception('Error parse uri $e');
      return {'data': e, 'statusCode': 500};
    }

    Map<String, String> headers = {
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.contentTypeHeader: 'application/json',
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
  }

  Future<Response> _get(Uri url, Map<String, String> headers) {
    _logger.d('Type: raw - get() with url ($url) - headers ($headers)');
    return http.get(url, headers: headers);
  }

  Future<Response> _post(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    _logger.d(
        'Type: raw - post() with url ($url) - headers ($headers) - body ($body)');
    return http.post(
      url,
      headers: headers,
      body: json.encode(body), /* encoding: Utf8Codec() */
    );
  }

  Future<Response> _put(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    _logger.d(
        'Type: raw - put() with url ($url) - headers ($headers) - body ($body)');
    return http.put(url,
        headers: headers, body: jsonEncode(body), encoding: const Utf8Codec());
  }

  Future<Response> _delete(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) {
    _logger.d(
        'Type: raw - delete() with url ($url) - headers ($headers) - body ($body)');
    return http.delete(url,
        headers: headers, body: jsonEncode(body), encoding: const Utf8Codec());
  }

  Map<String, dynamic> _handleResponse(Response response) {
    _logger.d('Response - statusCode: ${response.statusCode}');
    final decodedBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic>? map = cast<Map<String, dynamic>>(decodedBody);
      if (map != null) {
        map.addAll({'statusCode': response.statusCode});
        _logger.d('Response - body map: $map');
        return map;
      }
      map = {'data': decodedBody, 'statusCode': response.statusCode};
      _logger.d('Response - body map: $map');
      return map;
    }
    _logger.d('Response error ${response.body}');
    var map = cast<Map<String, dynamic>>(decodedBody);
    if (map != null) {
      map.addAll({'statusCode': response.statusCode});
      _logger.d('Response - body map: $map');
      return map;
    }
    map = {'data': decodedBody, 'statusCode': response.statusCode};
    _logger.d('Response - body map: $map');
    return map;
  }

  @override
  Future<Map<String, dynamic>> formData(
      {String? setApiUrl, required Endpoint endpoint}) async {
    try {
      Uri url = _defineUrl(endpoint: endpoint);
      var request = http.MultipartRequest(
          endpoint.method.name.toString().toUpperCase(), url);
      // headers from request form-data
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: '*/*',
      };

      request.headers.addAll(headers);
      request.headers.addAll(endpoint.headers);

      Map<String, String> body = {};
      endpoint.body.forEach((key, value) {
        body.addAll({key: value.toString()});
      });
      // agregamos los de texto a las al body
      request.fields.addAll(body);
      // agregamos los archivos al body
      if (endpoint.files.isNotEmpty) {
        // agregamos los files a al request convirtiendolos a MultipartFile
        for (ImagesModelEndpoint element in endpoint.files) {
          request.files.add(
            MultipartFile.fromBytes(element.key,
                await File.fromUri(Uri.parse(element.path)).readAsBytes(),
                filename: element.path,
                // identificamos el type y subtype de archivo
                contentType: MediaType('image', 'png')
                //element.path.split('.').last
                ),
          );
        }
      }
      _logger.d(
          'Type: form-data - ${endpoint.method.name}() with url ($url) - headers (${request.headers}) - body (${request.fields}) - files ${endpoint.files.map((e) => e.toJson())}');

      http.StreamedResponse response = await request.send();

      String data = await response.stream.bytesToString();
      final decodedBody = json.decode(data);
      return _responseMap(decodedBody, response.statusCode);
    } catch (e) {
      _logger.d('catch $e');
      Map<String, dynamic> map = {'data': e, 'statusCode': 500};
      return map;
    }
  }

  @override
  Future<Map<String, dynamic>> xWwwformurlencoded(
      {String? setApiUrl, required Endpoint endpoint}) async {
    try {
      Uri url = _defineUrl(endpoint: endpoint);

      var request =
          http.Request(endpoint.method.name.toString().toUpperCase(), url);
      // headers from request form-data
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        HttpHeaders.acceptHeader: '*/*',
      };
      request.headers.addAll(headers);
      Map<String, String> body = {};
      endpoint.body.forEach((key, value) {
        body.addAll({key: value.toString()});
      });
      // // agregamos los de texto a las al body
      request.bodyFields = body;

      _logger.d(
          'Type: x-www-form-urlencoded - ${endpoint.method.name}() with url ($url) - headers (${request.headers}) - body (${request.bodyFields})');
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final decodedBody = json.decode(await response.stream.bytesToString());

        Map<String, dynamic>? map = cast<Map<String, dynamic>>(decodedBody);
        return _responseMap(map, response.statusCode);
      } else {
        final decodedBody = json.decode(response.reasonPhrase!);
        _logger.d('Response body: $decodedBody');
        return json.decode(response.reasonPhrase!);
      }
    } catch (e) {
      _logger.d('catch $e');
      Map<String, dynamic> map = {'data': e, 'statusCode': 500};
      return map;
    }
  }

  Map<String, dynamic> _responseMap(
      Map<String, dynamic>? decodedBody, int statusCode) {
    // Map<String, dynamic>? map = cast<Map<String, dynamic>>(response);
    if (decodedBody != null) {
      decodedBody.addAll({'statusCode': statusCode});
      _logger.d('Response - status code: $statusCode - body map: $decodedBody');
      return decodedBody;
    } else {
      decodedBody = {'data': decodedBody, 'statusCode': statusCode};
      _logger.d('Response - status code: $statusCode - body map: $decodedBody');
      return decodedBody;
    }
  }

  Uri _defineUrl({required Endpoint endpoint}) {
    Protocol protocolo = const String.fromEnvironment('PROTOCOL').isNotEmpty &&
            const String.fromEnvironment('PROTOCOL').toString().toLowerCase() ==
                'http'
        ? Protocol.http
        : Protocol.https;

    // definimos el url de las variables de entorno
    String apiUrl = const String.fromEnvironment('DEBUG').isEmpty
        ? const String.fromEnvironment('DEBUG').toString().toLowerCase() ==
                'true'
            ? const String.fromEnvironment('API_URL')
            : const String.fromEnvironment('API_URL_PRODUCTION')
        : const String.fromEnvironment('API_URL');
    // si se usa la url diferente a las de environment

    if (endpoint.setApiUrl.isNotEmpty) {
      // validar si la setApiUrl contiene http o https=
      if (endpoint.setApiUrl.contains('http://')) {
        return _http(
            apiUrl: endpoint.setApiUrl,
            path: endpoint.path,
            queryParameters: endpoint.queryParameters);
      } else {
        return _https(
            apiUrl: endpoint.setApiUrl,
            path: endpoint.path,
            queryParameters: endpoint.queryParameters);
      }
    } else if (protocolo == Protocol.https || apiUrl.contains('https://')) {
      return _https(
          apiUrl: apiUrl,
          path: endpoint.path,
          queryParameters: endpoint.queryParameters);
    } else {
      return _http(
          apiUrl: apiUrl,
          path: endpoint.path,
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
