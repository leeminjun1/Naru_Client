import '../domain/auth_model.dart';

abstract class AuthRepository {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> signup(String email, String username, String password);
}
