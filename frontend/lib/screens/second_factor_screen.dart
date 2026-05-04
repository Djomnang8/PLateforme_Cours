import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class SecondFactorScreen extends StatefulWidget {
  final String email;
  const SecondFactorScreen({super.key, required this.email});
  @override State<SecondFactorScreen> createState() => _SecondFactorScreenState();
}

class _SecondFactorScreenState extends State<SecondFactorScreen> {
  final _matricule = TextEditingController();
  Future<void> _submit() async { await ApiService.verifyMatricule(widget.email, _matricule.text.trim()); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen(role: 'EMPLOYEE/ADMIN'))); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('2FA matricule')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text('Compte: ${widget.email}'), TextField(controller: _matricule, decoration: const InputDecoration(labelText: 'Matricule')), const SizedBox(height: 16), ElevatedButton(onPressed: _submit, child: const Text('Valider'))])));
}
