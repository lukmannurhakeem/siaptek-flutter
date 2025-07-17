import 'dart:convert';

class UserLoginModel {
  String? accessToken;
  String? refreshToken;
  User? user;
  int? expiresIn;

  UserLoginModel({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.expiresIn,
  });

  UserLoginModel copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    int? expiresIn,
  }) =>
      UserLoginModel(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        user: user ?? this.user,
        expiresIn: expiresIn ?? this.expiresIn,
      );

  factory UserLoginModel.fromRawJson(String str) => UserLoginModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        expiresIn: json["expires_in"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "refresh_token": refreshToken,
        "user": user?.toJson(),
        "expires_in": expiresIn,
      };
}

class User {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
