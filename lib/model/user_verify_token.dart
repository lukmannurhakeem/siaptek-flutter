import 'dart:convert';

class UserVerifyTokenModel {
  DateTime? expiresAt;
  int? expiresInSeconds;
  DateTime? issuedAt;
  int? userId;
  bool? valid;

  UserVerifyTokenModel({
    this.expiresAt,
    this.expiresInSeconds,
    this.issuedAt,
    this.userId,
    this.valid,
  });

  UserVerifyTokenModel copyWith({
    DateTime? expiresAt,
    int? expiresInSeconds,
    DateTime? issuedAt,
    int? userId,
    bool? valid,
  }) =>
      UserVerifyTokenModel(
        expiresAt: expiresAt ?? this.expiresAt,
        expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
        issuedAt: issuedAt ?? this.issuedAt,
        userId: userId ?? this.userId,
        valid: valid ?? this.valid,
      );

  factory UserVerifyTokenModel.fromRawJson(String str) => UserVerifyTokenModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserVerifyTokenModel.fromJson(Map<String, dynamic> json) => UserVerifyTokenModel(
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
        expiresInSeconds: json["expires_in_seconds"],
        issuedAt: json["issued_at"] == null ? null : DateTime.parse(json["issued_at"]),
        userId: json["user_id"],
        valid: json["valid"],
      );

  Map<String, dynamic> toJson() => {
        "expires_at": expiresAt?.toIso8601String(),
        "expires_in_seconds": expiresInSeconds,
        "issued_at": issuedAt?.toIso8601String(),
        "user_id": userId,
        "valid": valid,
      };
}
