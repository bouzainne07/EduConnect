import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return AuthRepository(apiService);
});

class AuthRepository {
  final AuthApiService _apiService;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._apiService);

  Future<UserModel> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    await _saveTokens(response);
    return _toUserModel(response);
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await _clearTokens();
    }
  }

  /// Restaure la session depuis le Secure Storage au démarrage de l'app.
  Future<UserModel?> restoreSession() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    final email = await _storage.read(key: AppConstants.userEmailKey);
    final role = await _storage.read(key: AppConstants.userRoleKey);
    final userId = await _storage.read(key: AppConstants.userIdKey);
    final firstName = await _storage.read(key: AppConstants.userFirstNameKey);
    final lastName = await _storage.read(key: AppConstants.userLastNameKey);

    if (token == null || email == null || role == null) return null;

    return UserModel(
      id: int.tryParse(userId ?? '') ?? 0,
      email: email,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      role: role,
    );
  }

  Future<void> _saveTokens(AuthResponse response) async {
    await _storage.write(key: AppConstants.tokenKey, value: response.accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: response.refreshToken);
    await _storage.write(key: AppConstants.userRoleKey, value: response.role);
    await _storage.write(key: AppConstants.userEmailKey, value: response.email);
    await _storage.write(key: AppConstants.userIdKey, value: response.userId.toString());
    await _storage.write(key: AppConstants.userFirstNameKey, value: response.firstName);
    await _storage.write(key: AppConstants.userLastNameKey, value: response.lastName);
  }

  Future<void> _clearTokens() async {
    await _storage.deleteAll();
  }

  UserModel _toUserModel(AuthResponse r) => UserModel(
        id: r.userId,
        email: r.email,
        firstName: r.firstName,
        lastName: r.lastName,
        role: r.role,
        photoUrl: r.photoUrl,
      );
}
