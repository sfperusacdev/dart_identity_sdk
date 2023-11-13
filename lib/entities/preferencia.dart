
class GrupoPreferencia {
    DateTime? created;
    String? descripcion;
    String? id;
    DateTime? updated;
    String? servicioId;
    List<Preferencia>? preferencias;

    GrupoPreferencia({
        this.created,
        this.descripcion,
        this.id,
        this.updated,
        this.servicioId,
        this.preferencias,
    });

    GrupoPreferencia copyWith({
        DateTime? created,
        String? descripcion,
        String? id,
        DateTime? updated,
        String? servicioId,
        List<Preferencia>? preferencias,
    }) => 
        GrupoPreferencia(
            created: created ?? this.created,
            descripcion: descripcion ?? this.descripcion,
            id: id ?? this.id,
            updated: updated ?? this.updated,
            servicioId: servicioId ?? this.servicioId,
            preferencias: preferencias ?? this.preferencias,
        );

    factory GrupoPreferencia.fromMap(Map<String, dynamic> json) => GrupoPreferencia(
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
        descripcion: json["descripcion"],
        id: json["id"],
        updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
        servicioId: json["servicio_id"],
        preferencias: json["preferencias"] == null ? [] : List<Preferencia>.from(json["preferencias"]!.map((x) => Preferencia.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "created": created?.toIso8601String(),
        "descripcion": descripcion,
        "id": id,
        "updated": updated?.toIso8601String(),
        "servicio_id": servicioId,
        "preferencias": preferencias == null ? [] : List<dynamic>.from(preferencias!.map((x) => x.toMap())),
    };
}

class Preferencia {
    String? id;
    String? identiticador;
    String? nombre;
    String? descripcion;
    bool? valor;
    String? tipoCampo;
    DateTime? updated;
    DateTime? created;
    String? grupoPreferenciaId;

    Preferencia({
        this.id,
        this.identiticador,
        this.nombre,
        this.descripcion,
        this.valor,
        this.tipoCampo,
        this.updated,
        this.created,
        this.grupoPreferenciaId,
    });

    Preferencia copyWith({
        String? id,
        String? identiticador,
        String? nombre,
        String? descripcion,
        bool? valor,
        String? tipoCampo,
        DateTime? updated,
        DateTime? created,
        String? grupoPreferenciaId,
    }) => 
        Preferencia(
            id: id ?? this.id,
            identiticador: identiticador ?? this.identiticador,
            nombre: nombre ?? this.nombre,
            descripcion: descripcion ?? this.descripcion,
            valor: valor ?? this.valor,
            tipoCampo: tipoCampo ?? this.tipoCampo,
            updated: updated ?? this.updated,
            created: created ?? this.created,
            grupoPreferenciaId: grupoPreferenciaId ?? this.grupoPreferenciaId,
        );

    factory Preferencia.fromMap(Map<String, dynamic> json) => Preferencia(
        id: json["id"],
        identiticador: json["identiticador"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        valor: json["valor"],
        tipoCampo: json["tipo_campo"],
        updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
        grupoPreferenciaId: json["grupo_preferencia_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "identiticador": identiticador,
        "nombre": nombre,
        "descripcion": descripcion,
        "valor": valor,
        "tipo_campo": tipoCampo,
        "updated": updated?.toIso8601String(),
        "created": created?.toIso8601String(),
        "grupo_preferencia_id": grupoPreferenciaId,
    };
}
