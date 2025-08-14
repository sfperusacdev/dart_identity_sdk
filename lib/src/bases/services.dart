import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String _defaultServiceID = "";

  static void setDefaultServiceID(String id) => _defaultServiceID = id;

  static Uri buildUri(
    String authority,
    String path, {
    Map<String, dynamic>? queryparams,
  }) {
    final uri = Uri.parse(authority);
    return uri.scheme == "https"
        ? Uri.https(uri.authority, path, queryparams)
        : Uri.http(uri.authority, path, queryparams);
  }

  static Uri uri(String path,
      {Map<String, dynamic>? queryparams, String? serviceID}) {
    final location =
        SessionManagerSDK.findServiceLocation(serviceID ?? _defaultServiceID);
    if (location == null) {
      throw ServiceLocationNotFoundErr(
          "Servicio `$serviceID` no encontrado 🥺🥺");
    }
    return buildUri(location, path, queryparams: queryparams);
  }

  static Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      "Authorization": SessionManagerSDK.getToken() ?? "",
    };
  }

  static Future<dynamic> _request(
      Future<http.Response> Function() requestFunc, Uri url) async {
    final client = http.Client();
    try {
      final response = await requestFunc();
      final decoded =
          json.decode(utf8.decode(response.bodyBytes)); // Decodificar en UTF-8

      if (response.statusCode ~/ 100 != 2) {
        throw ApiErrorResponse(_debugMessage(
            "API error",
            "Status Code: ${response.statusCode}",
            "Response: ${response.body}",
            url));
      }

      return decoded["data"];
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is SocketException) {
        errorMessage = _debugMessage("Connection Error", e.message, "", url);
        throw ConnectionRefuted(err: errorMessage, url: url);
      }
      if (e is HttpException) {
        errorMessage =
            _debugMessage("Invalid HTTP Response", e.message, "", url);
        throw ApiErrorResponse(errorMessage);
      }
      if (e is FormatException) {
        errorMessage =
            _debugMessage("Invalid Response Format", e.message, "", url);
        throw RespuestaInvalida();
      }
      if (e is TimeoutException) {
        errorMessage = _debugMessage(
            "Request Timed Out", "The request took too long", "", url);
        throw ApiErrorResponse(errorMessage);
      }
      if (e is http.ClientException) {
        errorMessage = _debugMessage("Client Error", e.message, "", url);
        throw ApiErrorResponse(errorMessage);
      }
      errorMessage = _debugMessage(
          "Unexpected Error", e.toString(), stackTrace.toString(), url);
      throw ApiErrorResponse(errorMessage);
    } finally {
      client.close();
    }
  }

  static String _debugMessage(
    String title,
    String message,
    String details,
    Uri url,
  ) {
    if (kDebugMode || kProfileMode) {
      return "[DEBUG] $title\n"
          "URL: $url\n"
          "Message: $message\n"
          "Details: ${details.isNotEmpty ? details : 'No additional details'}";
    } else {
      return message;
    }
  }

  static Future<dynamic> get({
    Uri? withUri,
    String? serviceID,
    String? path,
    Map<String, dynamic> qparams = const {},
    Duration? timeout,
  }) async {
    final url =
        withUri ?? uri(path ?? "", queryparams: qparams, serviceID: serviceID);
    return _request(
        () => http.get(url, headers: _headers()).timeout(
              timeout ?? const Duration(seconds: 30),
            ),
        url);
  }

  static Future<dynamic> post({
    Uri? withUri,
    String? serviceID,
    String? path,
    Object? payload = const {},
    Map<String, dynamic>? qparams,
  }) async {
    final url =
        withUri ?? uri(path ?? "", queryparams: qparams, serviceID: serviceID);
    return _request(
        () => http.post(url, body: jsonEncode(payload), headers: _headers()),
        url);
  }

  static Future<dynamic> delete({
    Uri? withUri,
    String? serviceID,
    String? path,
    Object? payload = const {},
    Map<String, dynamic>? qparams,
  }) async {
    final url =
        withUri ?? uri(path ?? "", queryparams: qparams, serviceID: serviceID);
    return _request(
      () => http.delete(url, body: jsonEncode(payload), headers: _headers()),
      url,
    );
  }

  static Future<dynamic> put({
    Uri? withUri,
    String? serviceID,
    String? path,
    Object? payload = const {},
    Map<String, dynamic>? qparams,
  }) async {
    final url =
        withUri ?? uri(path ?? "", queryparams: qparams, serviceID: serviceID);
    return _request(
        () => http.put(url, body: jsonEncode(payload), headers: _headers()),
        url);
  }
}
