import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget { const ForgotPasswordScreen({super.key}); @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState(); }
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _newPwd = TextEditingController();
  Future<void> _submit() async {
    try {
      await ApiService.forgotPassword(_email.text.trim(), _newPwd.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe réinitialisé avec succès')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mot de passe oublié')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')), TextField(controller: _newPwd, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau mot de passe')), const SizedBox(height: 16), ElevatedButton(onPressed: _submit, child: const Text('Réinitialiser'))])));
}
