class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://10.0.2.2:8081/api'; // Android emulator → localhost

  // Secure Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userIdKey = 'user_id';
  static const String userFirstNameKey = 'user_first_name';
  static const String userLastNameKey = 'user_last_name';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
