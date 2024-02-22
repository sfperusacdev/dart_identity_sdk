
class GrupoPreferencia {
    String? descripcion;
    String? id;
    String? servicioId;
    List<Preferencia>? preferencias;

    GrupoPreferencia({
        this.descripcion,
        this.id,
        this.servicioId,
        this.preferencias,
    });

    GrupoPreferencia copyWith({
        String? descripcion,
        String? id,
        String? servicioId,
        List<Preferencia>? preferencias,
    }) => 
        GrupoPreferencia(
            descripcion: descripcion ?? this.descripcion,
            id: id ?? this.id,
            servicioId: servicioId ?? this.servicioId,
            preferencias: preferencias ?? this.preferencias,
        );

    factory GrupoPreferencia.fromMap(Map<String, dynamic> json) => GrupoPreferencia(
        descripcion: json["descripcion"],
        id: json["id"],      
        servicioId: json["servicio_id"],
        preferencias: json["preferencias"] == null ? [] : List<Preferencia>.from(json["preferencias"]!.map((x) => Preferencia.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "descripcion": descripcion,
        "id": id,
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
    String? grupoPreferenciaId;

    Preferencia({
        this.id,
        this.identiticador,
        this.nombre,
        this.descripcion,
        this.valor,
        this.tipoCampo,
        this.grupoPreferenciaId,
    });

    Preferencia copyWith({
        String? id,
        String? identiticador,
        String? nombre,
        String? descripcion,
        bool? valor,
        String? tipoCampo,
        String? grupoPreferenciaId,
    }) => 
        Preferencia(
            id: id ?? this.id,
            identiticador: identiticador ?? this.identiticador,
            nombre: nombre ?? this.nombre,
            descripcion: descripcion ?? this.descripcion,
            valor: valor ?? this.valor,
            tipoCampo: tipoCampo ?? this.tipoCampo,
            grupoPreferenciaId: grupoPreferenciaId ?? this.grupoPreferenciaId,
        );

    factory Preferencia.fromMap(Map<String, dynamic> json) => Preferencia(
        id: json["id"],
        identiticador: json["identiticador"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        valor: json["valor"],
        tipoCampo: json["tipo_campo"],
        grupoPreferenciaId: json["grupo_preferencia_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "identiticador": identiticador,
        "nombre": nombre,
        "descripcion": descripcion,
        "valor": valor,
        "tipo_campo": tipoCampo,
        "grupo_preferencia_id": grupoPreferenciaId,
    };
}
