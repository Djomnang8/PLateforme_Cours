import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';
import 'second_factor_screen.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _submit() async {
    try {
      final data = await ApiService.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion réussie')));
      if (data['requiresSecondFactor'] == true) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SecondFactorScreen(email: data['email'])));
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen(role: data['role'].toString())));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _submit, child: const Text('Se connecter')),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), child: const Text('Mot de passe oublié ?')),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Créer un compte client'))
        ]),
      ));
}
