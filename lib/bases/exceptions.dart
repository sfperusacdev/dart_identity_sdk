class ConnectionRefuted implements Exception {
  final String? err;
  ConnectionRefuted({this.err});
  @override
  String toString() {
    return "No se pudo establecer connection, Error: $err 😑";
  }
}

class RespuestaInvalida implements Exception {
  @override
  String toString() {
    return "Formato de respuesta inválido 👎";
  }
}

class ApiEmptryResponse implements Exception {
  final String _message;
  ApiEmptryResponse(this._message);
  @override
  String toString() {
    return _message;
  }
}

class ApiErrorResponse implements Exception {
  final String _message;
  ApiErrorResponse(this._message);
  @override
  String toString() {
    return _message;
  }
}

class SessionError implements Exception {
  final String _message;
  SessionError(this._message);
  @override
  String toString() {
    return _message;
  }
}

class ServiceLocationNotFoundErr implements Exception {
  final String _message;
  ServiceLocationNotFoundErr(this._message);
  @override
  String toString() {
    return _message;
  }
}
