import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081/api';
    return 'http://10.0.2.2:8081/api';
  }

  static Future<dynamic> _requestJson(String method, String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final auth = UserSession.basicAuthHeader();
      if (auth.isNotEmpty) {
        headers['Authorization'] = auth;
      }

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

  // Auth
  static Future<void> registerLearner(String fullName, String email, String password) async {
    await _requestJson('POST', '/auth/register', body: {'fullName': fullName, 'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _requestJson('POST', '/auth/login', body: {'email': email, 'password': password});
    return (data as Map<String, dynamic>);
  }

  static Future<void> verifyMatricule(String email, String matricule) async {
    await _requestJson('POST', '/auth/verify-matricule', body: {'email': email, 'matricule': matricule});
  }

  static Future<void> forgotPassword(String email, String newPassword) async {
    await _requestJson('POST', '/auth/forgot-password', body: {'email': email, 'newPassword': newPassword});
  }

  // Courses
  static Future<List<dynamic>> getCourses() async => (await _requestJson('GET', '/courses')) as List<dynamic>;
  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> body) async =>
      (await _requestJson('POST', '/courses', body: body)) as Map<String, dynamic>;
  static Future<Map<String, dynamic>> updateCourse(int id, Map<String, dynamic> body) async =>
      (await _requestJson('PUT', '/courses/$id', body: body)) as Map<String, dynamic>;
  static Future<void> deleteCourse(int id) async => await _requestJson('DELETE', '/courses/$id');

  // Quizzes
  static Future<List<dynamic>> getQuizzes() async => (await _requestJson('GET', '/quizzes')) as List<dynamic>;
  // Quizzes
static Future<Map<String, dynamic>> createQuiz(Map<String, dynamic> body) async =>
    (await _requestJson('POST', '/quizzes', body: body)) as Map<String, dynamic>;
// Pour l'update, on envoie le même body
static Future<Map<String, dynamic>> updateQuiz(int id, Map<String, dynamic> body) async =>
    (await _requestJson('PUT', '/quizzes/$id', body: body)) as Map<String, dynamic>;
  static Future<void> deleteQuiz(int id) async => await _requestJson('DELETE', '/quizzes/$id');

  // Progress
  static Future<List<dynamic>> getProgress() async => (await _requestJson('GET', '/progress')) as List<dynamic>;
  static Future<Map<String, dynamic>> createProgress(Map<String, dynamic> body) async =>
      (await _requestJson('POST', '/progress', body: body)) as Map<String, dynamic>;
  static Future<Map<String, dynamic>> updateProgress(int id, Map<String, dynamic> body) async =>
      (await _requestJson('PUT', '/progress/$id', body: body)) as Map<String, dynamic>;
  static Future<void> deleteProgress(int id) async => await _requestJson('DELETE', '/progress/$id');
  static Future<List<dynamic>> getMyProgress() async => (await _requestJson('GET', '/progress/my')) as List<dynamic>;
  static Future<void> updateMyProgress(int courseId, int percent) async {
    await _requestJson('PUT', '/progress/my/$courseId', body: {'completionPercent': percent});
  }

  // Certifications
  static Future<List<dynamic>> getCertifications() async => (await _requestJson('GET', '/certifications')) as List<dynamic>;
  static Future<Map<String, dynamic>> createCertification(Map<String, dynamic> body) async =>
      (await _requestJson('POST', '/certifications', body: body)) as Map<String, dynamic>;
  static Future<Map<String, dynamic>> updateCertification(int id, Map<String, dynamic> body) async =>
      (await _requestJson('PUT', '/certifications/$id', body: body)) as Map<String, dynamic>;
  static Future<void> deleteCertification(int id) async => await _requestJson('DELETE', '/certifications/$id');
  static Future<List<dynamic>> getMyCertifications() async => (await _requestJson('GET', '/certifications/my')) as List<dynamic>;

  // Employees
  static Future<List<dynamic>> getEmployees() async => (await _requestJson('GET', '/employees')) as List<dynamic>;
  static Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> body) async =>
      (await _requestJson('POST', '/employees', body: body)) as Map<String, dynamic>;
  static Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> body) async =>
      (await _requestJson('PUT', '/employees/$id', body: body)) as Map<String, dynamic>;
  static Future<void> deleteEmployee(int id) async => await _requestJson('DELETE', '/employees/$id');

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async => (await _requestJson('GET', '/analytics')) as Map<String, dynamic>;
}