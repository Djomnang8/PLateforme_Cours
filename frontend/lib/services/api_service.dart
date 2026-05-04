import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode >= 400) throw Exception('Login invalide');
    return jsonDecode(res.body);
  }

  static Future<void> verifyMatricule(String email, String matricule) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/verify-matricule'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'matricule': matricule}));
    if (res.statusCode >= 400) throw Exception('Matricule invalide');
  }

  static Future<void> forgotPassword(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/forgot-password'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'newPassword': password}));
    if (res.statusCode >= 400) throw Exception('Erreur de réinitialisation');
  }
}
