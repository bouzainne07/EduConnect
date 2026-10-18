import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// État de l'authentification
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(UserModel user)
      : this(status: AuthStatus.authenticated, user: user);
  const AuthState.error(String message)
      : this(status: AuthStatus.unauthenticated, error: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  String? get role => user?.role;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late AuthRepository _repository;

  @override
  Future<AuthState> build() async {
    _repository = ref.read(authRepositoryProvider);
    // Tentative de restauration de session au démarrage
    final user = await _repository.restoreSession();
    if (user != null) {
      return AuthState.authenticated(user);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncData(AuthState.loading());
    try {
      final user = await _repository.login(email, password);
      state = AsyncData(AuthState.authenticated(user));
    } catch (e) {
      state = AsyncData(AuthState.error(_parseError(e)));
    }
  }

  Future<void> logout() async {
    state = const AsyncData(AuthState.loading());
    try {
      await _repository.logout();
    } finally {
      state = const AsyncData(AuthState.unauthenticated());
    }
  }

  String _parseError(Object e) {
    // Dio retourne DioException avec response.data
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Email ou mot de passe incorrect';
    }
    if (msg.contains('SocketException') || msg.contains('connection')) {
      return 'Impossible de contacter le serveur';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
