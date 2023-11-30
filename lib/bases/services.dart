import 'dart:convert';
import 'dart:io';

import 'package:dart_identity_sdk/bases/exceptions.dart';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:http/http.dart' as http;

const tareoServiceID = "com.sfperusac.contratos";

class ApiService {
  static Uri parseUri(String authority, String path, {Map<String, dynamic>? queryparams}) {
    var uri = Uri.parse(authority);
    if (uri.scheme == "https") {
      return Uri.https(uri.authority, path, queryparams);
    }
    return Uri.http(uri.authority, path, queryparams);
  }

  static Uri uri(String path, {Map<String, dynamic>? queryparams, String? serviceID}) {
    final manager = SessionManagerSDK();
    var location = manager.findServiceLocation(serviceID ?? tareoServiceID);
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
  }) =>
      get("", qparams: qparams, useUri: useUri, serviceID: serviceID);

  static Future get(
    String path, {
    Map<String, dynamic> qparams = const {},
    Uri? useUri,
    String? serviceID,
  }) async {
    var client = http.Client();
    try {
      final response = await client.get(
        useUri ?? uri(path, queryparams: qparams, serviceID: serviceID),
        headers: _myHeaders(),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw NoInternet();
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
    try {
      final response = await client.post(
        useUri ?? uri(path, queryparams: qparams, serviceID: serviceID),
        body: jsonEncode(payload),
        headers: _myHeaders(),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw NoInternet();
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
    try {
      final response = await client.delete(
        useUri ?? uri(path, queryparams: qparams, serviceID: serviceID),
        body: jsonEncode(payload),
        headers: _myHeaders(),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw NoInternet();
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
    try {
      final response = await client.put(
        useUri ?? uri(path, queryparams: qparams, serviceID: serviceID),
        body: jsonEncode(payload),
        headers: _myHeaders(),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode / 100).truncate() != 2) {
        throw ApiErrorResponse(decoded["message"]);
      }
      return decoded["data"];
    } catch (e) {
      if (e is SocketException) throw NoInternet();
      if (e is HttpException) throw ApiErrorResponse("Couldn't find the post 😱");
      if (e is FormatException) throw RespuestaInvalida();
      rethrow;
    } finally {
      client.close();
    }
  }
}
