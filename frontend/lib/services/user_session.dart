import 'dart:convert';

class UserSession {
  static String? _email;
  static String? _password;
  static String? role;

  static void setCredentials(String email, String password, String userRole) {
    _email = email;
    _password = password;
    role = userRole;
  }

  static String basicAuthHeader() {
    if (_email == null || _password == null) return '';
    final token = base64.encode(utf8.encode('$_email:$_password'));
    return 'Basic $token';
  }

  static void clear() {
    _email = null;
    _password = null;
    role = null;
  }

  static bool get isLoggedIn => _email != null;
}