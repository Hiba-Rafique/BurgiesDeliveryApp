import 'package:hive/hive.dart';

part 'user.g.dart'; 

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
    };
  }
}
