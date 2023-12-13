import 'dart:convert';

List<Licence> licenceFromJson(String str) => List<Licence>.from(json.decode(str).map((x) => Licence.fromMap(x)));

String licenceToJson(List<Licence> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Licence {
  String? licenceCode;
  String? companyCode;
  String? company;
  bool? allowed;

  Licence({
    this.licenceCode,
    this.companyCode,
    this.company,
    this.allowed,
  });

  Licence copyWith({
    String? licenceCode,
    String? companyCode,
    String? company,
    bool? allowed,
  }) =>
      Licence(
        licenceCode: licenceCode ?? this.licenceCode,
        companyCode: companyCode ?? this.companyCode,
        company: company ?? this.company,
        allowed: allowed ?? this.allowed,
      );

  factory Licence.fromMap(Map<String, dynamic> json) => Licence(
        licenceCode: json["licence_code"],
        companyCode: json["company_code"],
        company: json["company"],
        allowed: json["allowed"],
      );

  Map<String, dynamic> toMap() => {
        "licence_code": licenceCode,
        "company_code": companyCode,
        "company": company,
        "allowed": allowed,
      };
}
