class SyncPayloadResponse {
  final List<String> identifiers;
  final List<Map<String, Object?>> payload;

  const SyncPayloadResponse({
    this.identifiers = const [],
    this.payload = const [],
  });

  factory SyncPayloadResponse.fromMap(Map<String, Object?> json) {
    final identifiers = json['identifiers'] == null
        ? <String>[]
        : List<String>.from(json['identifiers'] as Iterable);
    final rawPayload = json['payload'];
    final payload = rawPayload == null
        ? <Map<String, Object?>>[]
        : List<Map<String, Object?>>.from(
            (rawPayload as Iterable).map(
              (item) => Map<String, Object?>.from(item as Map),
            ),
          );

    return SyncPayloadResponse(
      identifiers: identifiers,
      payload: payload,
    );
  }
}
