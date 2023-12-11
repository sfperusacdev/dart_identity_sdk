part of './dart_identity_sdk.dart';

class _ApiErrorResponse implements Exception {
  final String _message;
  _ApiErrorResponse(this._message);
  @override
  String toString() => _message;
}

Future _postlogin({
  required Uri uri,
  Object? payload = const {},
}) async {
  var client = http.Client();
  try {
    final response = await client.post(
      uri,
      body: jsonEncode(payload),
      headers: {"Content-Type": "application/json"},
    );
    final decoded = json.decode(response.body);
    if ((response.statusCode / 100).truncate() != 2) {
      throw _ApiErrorResponse(decoded["message"] ?? 'Error desconocido en la API.');
    }
    return decoded["data"];
  } catch (e) {
    if (e is _ApiErrorResponse) rethrow;
    if (e.toString().contains('SocketException')) {
      throw Exception('Error de conexión a Internet o con el servicio. Verifica tu conexión.');
    } else if (e.toString().contains('HttpException')) {
      throw Exception('Error en la solicitud HTTP. Comprueba la URL.');
    } else if (e.toString().contains('FormatException')) {
      throw Exception('Error de formato. La respuesta no es un JSON válido.');
    } else {
      throw Exception('Otro tipo de error. Comunícate con el soporte técnico.');
    }
  } finally {
    client.close();
  }
}
