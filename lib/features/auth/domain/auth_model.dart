class AuthModel {
  final String email;
  final String? username;
  final String token;

  const AuthModel({
    required this.email,
    this.username,
    required this.token,
  });
}
