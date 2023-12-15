import 'dart:convert';

import 'package:dart_identity_sdk/src/entities/empresa_app_perfile.dart';

class Empresa {
  String? code;
  String? description;
  String? businessName;
  String? businessDoc;
  String? address;
  bool? isDisabled;
  String? comment;
  String? imageLocation;
  DateTime? createdAt;
  String? createdBy;
  DateTime? writeAt;
  String? writeBy;
  List<EmpresaAppPerfil> perfiles = [];
  Empresa({
    this.code,
    this.description,
    this.businessName,
    this.businessDoc,
    this.address,
    this.isDisabled,
    this.comment,
    this.imageLocation,
    this.createdAt,
    this.createdBy,
    this.writeAt,
    this.writeBy,
  });

  Empresa copyWith({
    String? code,
    String? description,
    String? businessName,
    String? businessDoc,
    String? address,
    bool? isDisabled,
    String? comment,
    String? imageLocation,
    DateTime? createdAt,
    String? createdBy,
    DateTime? writeAt,
    String? writeBy,
  }) =>
      Empresa(
        code: code ?? this.code,
        description: description ?? this.description,
        businessName: businessName ?? this.businessName,
        businessDoc: businessDoc ?? this.businessDoc,
        address: address ?? this.address,
        isDisabled: isDisabled ?? this.isDisabled,
        comment: comment ?? this.comment,
        imageLocation: imageLocation ?? this.imageLocation,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        writeAt: writeAt ?? this.writeAt,
        writeBy: writeBy ?? this.writeBy,
      );

  factory Empresa.fromJson(String str) => Empresa.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Empresa.fromMap(Map<String, dynamic> json) => Empresa(
        code: json["code"],
        description: json["description"],
        businessName: json["business_name"],
        businessDoc: json["business_doc"],
        address: json["address"],
        isDisabled: json["is_disabled"],
        comment: json["comment"],
        imageLocation: json["image_location"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        writeAt: json["write_at"] == null ? null : DateTime.parse(json["write_at"]),
        writeBy: json["write_by"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "description": description,
        "business_name": businessName,
        "business_doc": businessDoc,
        "address": address,
        "is_disabled": isDisabled,
        "comment": comment,
        "image_location": imageLocation,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy,
        "write_at": writeAt?.toIso8601String(),
        "write_by": writeBy,
        "perfiles": perfiles.map((e) => e.toMap()).toList(),
      };
}
