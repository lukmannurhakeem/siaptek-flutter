// To parse this JSON data, do
//
//     final userLoginModel = userLoginModelFromJson(jsonString);

import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) => UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
  String? accessToken;
  String? refreshToken;
  User? user;
  int? expiresIn;

  UserLoginModel({this.accessToken, this.refreshToken, this.user, this.expiresIn});

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
  String? username;
  String? divisionid;
  String? code;
  bool? passwordReset;
  bool? isAccountLocked;
  String? userGroup;
  String? firstName;
  String? lastName;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.email,
    this.username,
    this.divisionid,
    this.code,
    this.passwordReset,
    this.isAccountLocked,
    this.userGroup,
    this.firstName,
    this.lastName,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    email: json["email"],
    username: json["username"],
    divisionid: json["divisionid"],
    code: json["code"],
    passwordReset: json["password_reset"],
    isAccountLocked: json["is_account_locked"],
    userGroup: json["user_group"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "username": username,
    "divisionid": divisionid,
    "code": code,
    "password_reset": passwordReset,
    "is_account_locked": isAccountLocked,
    "user_group": userGroup,
    "first_name": firstName,
    "last_name": lastName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
