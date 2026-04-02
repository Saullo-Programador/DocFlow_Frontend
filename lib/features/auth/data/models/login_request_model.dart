/// Modelo de requisição de login
class LoginRequestModel {
  final String name;
  final String password;

  LoginRequestModel({
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
    };
  }
}
