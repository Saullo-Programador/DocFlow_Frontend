/// Modelo de requisição de registro
class RegisterRequestModel {
  final String email;
  final String password;
  final String? name;

  RegisterRequestModel({
    required this.email,
    required this.password,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
    };
  }
}
