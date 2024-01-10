import 'dart:convert';

class RefreshTokenResponse {
  final String? date;
  final int? timeStamp;
  final String? token;

  RefreshTokenResponse({
    this.date,
    this.timeStamp,
    this.token,
  });

  RefreshTokenResponse copyWith({
    String? date,
    int? timeStamp,
    String? token,
  }) =>
      RefreshTokenResponse(
        date: date ?? this.date,
        timeStamp: timeStamp ?? this.timeStamp,
        token: token ?? this.token,
      );

  factory RefreshTokenResponse.fromJson(String str) => RefreshTokenResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RefreshTokenResponse.fromMap(Map<String, dynamic> json) => RefreshTokenResponse(
        date: json["date"],
        timeStamp: json["time_stamp"],
        token: json["token"],
      );

  Map<String, dynamic> toMap() => {
        "date": date,
        "time_stamp": timeStamp,
        "token": token,
      };
}
