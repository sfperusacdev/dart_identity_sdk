import 'dart:convert';

class IdentitySessionResponse {
  DateTime? date;
  int? timeStamp;
  String? token;
  String? userCode;
  List<Location>? locations;
  Device? device;
  List<Sucursale>? sucursales;
  Usuario? usuario;
  Session? session;

  IdentitySessionResponse({
    this.date,
    this.timeStamp,
    this.token,
    this.userCode,
    this.locations,
    this.device,
    this.sucursales,
    this.usuario,
    this.session,
  });

  IdentitySessionResponse copyWith({
    DateTime? date,
    int? timeStamp,
    String? token,
    String? userCode,
    List<Location>? locations,
    Device? device,
    List<Sucursale>? sucursales,
    Usuario? usuario,
    Session? session,
  }) =>
      IdentitySessionResponse(
        date: date ?? this.date,
        timeStamp: timeStamp ?? this.timeStamp,
        token: token ?? this.token,
        userCode: userCode ?? this.userCode,
        locations: locations ?? this.locations,
        device: device ?? this.device,
        sucursales: sucursales ?? this.sucursales,
        usuario: usuario ?? this.usuario,
        session: session ?? this.session,
      );

  factory IdentitySessionResponse.fromJson(String str) => IdentitySessionResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory IdentitySessionResponse.fromMap(Map<String, dynamic> json) => IdentitySessionResponse(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        timeStamp: json["time_stamp"],
        token: json["token"],
        userCode: json["user_code"],
        locations:
            json["locations"] == null ? [] : List<Location>.from(json["locations"]!.map((x) => Location.fromMap(x))),
        device: json["device"] == null ? null : Device.fromMap(json["device"]),
        sucursales: json["sucursales"] == null
            ? []
            : List<Sucursale>.from(json["sucursales"]!.map((x) => Sucursale.fromMap(x))),
        usuario: json["usuario"] == null ? null : Usuario.fromMap(json["usuario"]),
        session: json["session"] == null ? null : Session.fromMap(json["session"]),
      );

  Map<String, dynamic> toMap() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "time_stamp": timeStamp,
        "token": token,
        "user_code": userCode,
        "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toMap())),
        "device": device?.toMap(),
        "sucursales": sucursales == null ? [] : List<dynamic>.from(sucursales!.map((x) => x.toMap())),
        "usuario": usuario?.toMap(),
        "session": session?.toMap(),
      };
}

class Device {
  String? code;
  String? description;
  String? deviceIdentifier;
  String? deviceInfo;
  String? companyLicenceCode;
  DateTime? createdAt;
  String? createdBy;
  DateTime? writeAt;
  String? writeBy;

  Device({
    this.code,
    this.description,
    this.deviceIdentifier,
    this.deviceInfo,
    this.companyLicenceCode,
    this.createdAt,
    this.createdBy,
    this.writeAt,
    this.writeBy,
  });

  Device copyWith({
    String? code,
    String? description,
    String? deviceIdentifier,
    String? deviceInfo,
    String? companyLicenceCode,
    DateTime? createdAt,
    String? createdBy,
    DateTime? writeAt,
    String? writeBy,
  }) =>
      Device(
        code: code ?? this.code,
        description: description ?? this.description,
        deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
        deviceInfo: deviceInfo ?? this.deviceInfo,
        companyLicenceCode: companyLicenceCode ?? this.companyLicenceCode,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        writeAt: writeAt ?? this.writeAt,
        writeBy: writeBy ?? this.writeBy,
      );

  factory Device.fromJson(String str) => Device.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Device.fromMap(Map<String, dynamic> json) => Device(
        code: json["code"],
        description: json["description"],
        deviceIdentifier: json["device_identifier"],
        deviceInfo: json["device_info"],
        companyLicenceCode: json["company_licence_code"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        writeAt: json["write_at"] == null ? null : DateTime.parse(json["write_at"]),
        writeBy: json["write_by"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "description": description,
        "device_identifier": deviceIdentifier,
        "device_info": deviceInfo,
        "company_licence_code": companyLicenceCode,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy,
        "write_at": writeAt?.toIso8601String(),
        "write_by": writeBy,
      };
}

class Location {
  String? codigo;
  String? location;

  Location({
    this.codigo,
    this.location,
  });

  Location copyWith({
    String? codigo,
    String? location,
  }) =>
      Location(
        codigo: codigo ?? this.codigo,
        location: location ?? this.location,
      );

  factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Location.fromMap(Map<String, dynamic> json) => Location(
        codigo: json["codigo"],
        location: json["location"],
      );

  Map<String, dynamic> toMap() => {
        "codigo": codigo,
        "location": location,
      };
}

class Session {
  String? company;
  String? username;
  List<String>? supervisors;
  List<String>? subordinates;
  List<Permission>? permissions;

  Session({
    this.company,
    this.username,
    this.supervisors,
    this.subordinates,
    this.permissions,
  });

  Session copyWith({
    String? company,
    String? username,
    List<String>? supervisors,
    List<String>? subordinates,
    List<Permission>? permissions,
  }) =>
      Session(
        company: company ?? this.company,
        username: username ?? this.username,
        supervisors: supervisors ?? this.supervisors,
        subordinates: subordinates ?? this.subordinates,
        permissions: permissions ?? this.permissions,
      );

  factory Session.fromJson(String str) => Session.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Session.fromMap(Map<String, dynamic> json) => Session(
        company: json["company"],
        username: json["username"],
        supervisors: json["supervisors"] == null ? [] : List<String>.from(json["supervisors"]!.map((x) => x)),
        subordinates: json["subordinates"] == null ? [] : List<String>.from(json["subordinates"]!.map((x) => x)),
        permissions: json["permissions"] == null
            ? []
            : List<Permission>.from(json["permissions"]!.map((x) => Permission.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "company": company,
        "username": username,
        "supervisors": supervisors == null ? [] : List<dynamic>.from(supervisors!.map((x) => x)),
        "subordinates": subordinates == null ? [] : List<dynamic>.from(subordinates!.map((x) => x)),
        "permissions": permissions == null ? [] : List<dynamic>.from(permissions!.map((x) => x.toMap())),
      };
}

class Permission {
  String? id;
  List<String>? companyBrances;

  Permission({
    this.id,
    this.companyBrances,
  });

  Permission copyWith({
    String? id,
    List<String>? companyBrances,
  }) =>
      Permission(
        id: id ?? this.id,
        companyBrances: companyBrances ?? this.companyBrances,
      );

  factory Permission.fromJson(String str) => Permission.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Permission.fromMap(Map<String, dynamic> json) => Permission(
        id: json["id"],
        companyBrances:
            json["company_brances"] == null ? [] : List<String>.from(json["company_brances"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "company_brances": companyBrances == null ? [] : List<dynamic>.from(companyBrances!.map((x) => x)),
      };
}

class Sucursale {
  String? code;
  String? description;
  String? address;
  String? companyCode;
  bool? isDisabled;
  DateTime? createdAt;
  String? createdBy;
  DateTime? writeAt;
  String? writeBy;

  Sucursale({
    this.code,
    this.description,
    this.address,
    this.companyCode,
    this.isDisabled,
    this.createdAt,
    this.createdBy,
    this.writeAt,
    this.writeBy,
  });

  Sucursale copyWith({
    String? code,
    String? description,
    String? address,
    String? companyCode,
    bool? isDisabled,
    DateTime? createdAt,
    String? createdBy,
    DateTime? writeAt,
    String? writeBy,
  }) =>
      Sucursale(
        code: code ?? this.code,
        description: description ?? this.description,
        address: address ?? this.address,
        companyCode: companyCode ?? this.companyCode,
        isDisabled: isDisabled ?? this.isDisabled,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        writeAt: writeAt ?? this.writeAt,
        writeBy: writeBy ?? this.writeBy,
      );

  factory Sucursale.fromJson(String str) => Sucursale.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Sucursale.fromMap(Map<String, dynamic> json) => Sucursale(
        code: json["code"],
        description: json["description"],
        address: json["address"],
        companyCode: json["company_code"],
        isDisabled: json["is_disabled"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        writeAt: json["write_at"] == null ? null : DateTime.parse(json["write_at"]),
        writeBy: json["write_by"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "description": description,
        "address": address,
        "company_code": companyCode,
        "is_disabled": isDisabled,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy,
        "write_at": writeAt?.toIso8601String(),
        "write_by": writeBy,
      };
}

class Usuario {
  String? code;
  String? username;
  String? companyCode;
  String? fullName;
  bool? isDisabled;
  int? passwordAttempts;
  String? referenceCode;
  String? externalReference;
  DateTime? createdAt;
  String? createdBy;
  DateTime? writeAt;
  String? writeBy;

  Usuario({
    this.code,
    this.username,
    this.companyCode,
    this.fullName,
    this.isDisabled,
    this.passwordAttempts,
    this.referenceCode,
    this.externalReference,
    this.createdAt,
    this.createdBy,
    this.writeAt,
    this.writeBy,
  });

  Usuario copyWith({
    String? code,
    String? username,
    String? companyCode,
    String? fullName,
    bool? isDisabled,
    int? passwordAttempts,
    String? referenceCode,
    String? externalReference,
    DateTime? createdAt,
    String? createdBy,
    DateTime? writeAt,
    String? writeBy,
  }) =>
      Usuario(
        code: code ?? this.code,
        username: username ?? this.username,
        companyCode: companyCode ?? this.companyCode,
        fullName: fullName ?? this.fullName,
        isDisabled: isDisabled ?? this.isDisabled,
        passwordAttempts: passwordAttempts ?? this.passwordAttempts,
        referenceCode: referenceCode ?? this.referenceCode,
        externalReference: externalReference ?? this.externalReference,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        writeAt: writeAt ?? this.writeAt,
        writeBy: writeBy ?? this.writeBy,
      );

  factory Usuario.fromJson(String str) => Usuario.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Usuario.fromMap(Map<String, dynamic> json) => Usuario(
        code: json["code"],
        username: json["username"],
        companyCode: json["company_code"],
        fullName: json["full_name"],
        isDisabled: json["is_disabled"],
        passwordAttempts: json["password_attempts"],
        referenceCode: json["reference_code"],
        externalReference: json["external_reference"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        writeAt: json["write_at"] == null ? null : DateTime.parse(json["write_at"]),
        writeBy: json["write_by"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "username": username,
        "company_code": companyCode,
        "full_name": fullName,
        "is_disabled": isDisabled,
        "password_attempts": passwordAttempts,
        "reference_code": referenceCode,
        "external_reference": externalReference,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy,
        "write_at": writeAt?.toIso8601String(),
        "write_by": writeBy,
      };
}
