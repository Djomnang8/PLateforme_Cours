import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081/api';
    return 'http://10.0.2.2:8081/api';
  }

  static Future<Map<String, dynamic>> _postJson(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$endpoint'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode >= 400) {
        final err = res.body.isNotEmpty ? jsonDecode(res.body) : {'error': 'Erreur HTTP ${res.statusCode}'};
        throw Exception(err['error'] ?? 'Erreur HTTP ${res.statusCode}');
      }
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw Exception('Connexion expirée. Vérifiez que le backend tourne sur $baseUrl');
    } catch (e) {
      throw Exception('Échec requête $endpoint: $e');
    }
  }

  static Future<void> registerLearner(String fullName, String email, String password) async {
    await _postJson('/auth/register', {'fullName': fullName, 'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    return _postJson('/auth/login', {'email': email, 'password': password});
  }

  static Future<void> verifyMatricule(String email, String matricule) async {
    await _postJson('/auth/verify-matricule', {'email': email, 'matricule': matricule});
  }

  static Future<void> forgotPassword(String email, String password) async {
    await _postJson('/auth/forgot-password', {'email': email, 'newPassword': password});
  }
}
