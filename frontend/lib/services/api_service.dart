import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081/api';
    return 'http://10.0.2.2:8081/api';
  }

  static Future<dynamic> _requestJson(String method, String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {'Content-Type': 'application/json'};
      late final http.Response res;
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));
          break;
        case 'POST':
          res = await http.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 12));
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 12));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 12));
          break;
        default:
          throw Exception('Méthode non supportée: $method');
      }

      if (res.statusCode >= 400) {
        final err = res.body.isNotEmpty ? jsonDecode(res.body) : {'error': 'Erreur HTTP ${res.statusCode}'};
        throw Exception(err['error'] ?? 'Erreur HTTP ${res.statusCode}');
      }

      if (res.body.isEmpty) return {};
      return jsonDecode(res.body);
    } on TimeoutException {
      throw Exception('Connexion expirée. Vérifiez que le backend tourne sur $baseUrl');
    } catch (e) {
      throw Exception('Échec requête $endpoint: $e');
    }
  }

  static Future<Map<String, dynamic>> _postJson(String endpoint, Map<String, dynamic> body) async {
    final data = await _requestJson('POST', endpoint, body: body);
    return (data as Map<String, dynamic>);
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

  static Future<List<dynamic>> getCourses() async => (await _requestJson('GET', '/courses')) as List<dynamic>;
  static Future<List<dynamic>> getQuizzes() async => (await _requestJson('GET', '/quizzes')) as List<dynamic>;
  static Future<List<dynamic>> getProgress() async => (await _requestJson('GET', '/progress')) as List<dynamic>;
  static Future<List<dynamic>> getCertifications() async => (await _requestJson('GET', '/certifications')) as List<dynamic>;
  static Future<Map<String, dynamic>> getAnalytics() async => (await _requestJson('GET', '/analytics')) as Map<String, dynamic>;
  static Future<List<dynamic>> getEmployees() async => (await _requestJson('GET', '/employees')) as List<dynamic>;
}
