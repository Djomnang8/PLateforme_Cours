import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _submit() async {
    await ApiService.registerLearner(_name.text.trim(), _email.text.trim(), _password.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inscription client')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom complet')),
        TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _submit, child: const Text('S\'inscrire'))
      ]),
    ),
  );
}
