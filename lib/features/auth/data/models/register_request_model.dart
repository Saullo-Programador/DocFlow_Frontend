import 'package:manege_doc/core/constants/type_role.dart';

/// Modelo de requisição de registro
class RegisterRequestModel {
  final String email;
  final String password;
  final String? name;
  final TypeRole role;

  RegisterRequestModel({
    required this.email,
    required this.password,
    this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
      if (name != null) 'name': name,
    };
  }
}
