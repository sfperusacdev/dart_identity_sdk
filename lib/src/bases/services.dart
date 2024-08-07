import 'dart:convert';
import 'dart:io';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static var _defaultServiceID = "";
  static void setDefaultServiceID(String id) {
    _defaultServiceID = id;
  }

  static Uri parseUri(String authority, String path, {Map<String, dynamic>? queryparams}) {
    var uri = Uri.parse(authority);
    if (uri.scheme == "https") {
      return Uri.https(uri.authority, path, queryparams);
    }
    return Uri.http(uri.authority, path, queryparams);
  }

  static Uri uri(String path, {Map<String, dynamic>? queryparams, String? serviceID}) {
    final manager = SessionManagerSDK();
    var location = manager.findServiceLocation(serviceID ?? _defaultServiceID);
    if (location == null) {
      throw ServiceLocationNotFoundErr("Servicio `$serviceID` no encontrado 🥺🥺");
    }
    return ApiService.parseUri(location, path, queryparams: queryparams);
  }

  static Map<String, String> _myHeaders() {
    final manager = SessionManagerSDK();
    return {
      "Content-Type": "application/json",
      "Authorization": manager.getToken() ?? "",
    };
  }

  static Future getWithUri(
    Uri useUri, {
    Map<String, dynamic> qparams = const {},
    String? serviceID,
    Duration? timeout,
  }) =>
      get("", qparams: qparams, useUri: useUri, serviceID: serviceID, timeout: timeout);

  static Future get(
    String path, {
    Map<String, dynamic> qparams = const {},
    Uri? useUri,
    String? serviceID,
    Duration? timeout,
  }) async {
    var client = http.Client();
    late Uri url;
    try {
      url = useUri ?? uri(path, queryparams: qparams, serviceID: serviceID);
      http.Response response;
      if (timeout == null) {
        response = await client.get(url, headers: _myHeaders());
      } else {
        response = await client.get(url, headers: _myHeaders()).timeout(timeout);
      }
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw ConnectionRefuted(err: e.message, url: url);
      if (e is HttpException) {
        throw ApiErrorResponse("Couldn't find the post 😱");
      }
      if (e is FormatException) throw RespuestaInvalida();
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future postWithUri(
    Uri useUri, {
    Map<String, dynamic> payload = const {},
    Map<String, dynamic> qparams = const {},
    String? serviceID,
  }) =>
      post(
        "",
        payload: payload,
        qparams: qparams,
        useUri: useUri,
        serviceID: serviceID,
      );

  static Future post(
    String path, {
    Object? payload = const {},
    Map<String, dynamic>? qparams,
    Uri? useUri,
    String? serviceID,
  }) async {
    var client = http.Client();
    late Uri url;
    try {
      url = useUri ?? uri(path, queryparams: qparams, serviceID: serviceID);
      final response = await client.post(url, body: jsonEncode(payload), headers: _myHeaders());
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw ConnectionRefuted(err: e.message, url: url);
      if (e is HttpException) throw ApiErrorResponse("Couldn't find the post 😱");
      if (e is FormatException) throw RespuestaInvalida();
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future delete(
    String path, {
    Object? payload = const {},
    Map<String, dynamic>? qparams,
    Uri? useUri,
    String? serviceID,
  }) async {
    var client = http.Client();
    late Uri url;
    try {
      url = useUri ?? uri(path, queryparams: qparams, serviceID: serviceID);
      final response = await client.delete(url, body: jsonEncode(payload), headers: _myHeaders());
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw ConnectionRefuted(err: e.message, url: url);
      if (e is HttpException) throw ApiErrorResponse("Couldn't find the post 😱");
      if (e is FormatException) throw RespuestaInvalida();
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future put(
    String path, {
    Object? payload = const {},
    Map<String, String> qparams = const {},
    Uri? useUri,
    String? serviceID,
  }) async {
    var client = http.Client();
    late Uri url;
    try {
      url = useUri ?? uri(path, queryparams: qparams, serviceID: serviceID);
      final response = await client.put(url, body: jsonEncode(payload), headers: _myHeaders());
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw ConnectionRefuted(err: e.message, url: url);
      if (e is HttpException) throw ApiErrorResponse("Couldn't find the post 😱");
      if (e is FormatException) throw RespuestaInvalida();
      rethrow;
    } finally {
      client.close();
    }
  }
}
