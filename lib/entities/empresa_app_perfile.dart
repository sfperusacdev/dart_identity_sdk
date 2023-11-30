class EmpresaAppPerfil {
  String? id;
  String? descripcion;
  String? empresaCodigo;

  EmpresaAppPerfil({
    this.id,
    this.descripcion,
    this.empresaCodigo,
  });

  EmpresaAppPerfil copyWith({
    String? id,
    String? descripcion,
    String? empresaCodigo,
  }) =>
      EmpresaAppPerfil(
        id: id ?? this.id,
        descripcion: descripcion ?? this.descripcion,
        empresaCodigo: empresaCodigo ?? this.empresaCodigo,
      );

  factory EmpresaAppPerfil.fromMap(Map<String, dynamic> json) => EmpresaAppPerfil(
        id: json["id"],
        descripcion: json["descripcion"],
        empresaCodigo: json["empresa_codigo"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "descripcion": descripcion,
        "empresa_codigo": empresaCodigo,
      };
  @override
  String toString() {
    return descripcion ?? "";
  }
}
