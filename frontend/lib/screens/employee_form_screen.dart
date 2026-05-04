import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;
  const EmployeeFormScreen({super.key, this.employee});
  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _matricule = TextEditingController();
  String _role = 'ROLE_EMPLOYEE';

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _name.text = widget.employee!['fullName'] ?? '';
      _email.text = widget.employee!['email'] ?? '';
      // password non affiché, on laisse vide (si inchangé, on pourrait ne pas le modifier)
      _matricule.text = widget.employee!['matricule'] ?? '';
      _role = widget.employee!['role'] ?? 'ROLE_EMPLOYEE';
    }
  }

  Future<void> _save() async {
    final body = {
      'fullName': _name.text,
      'email': _email.text,
      'password': _password.text.isNotEmpty ? _password.text : (widget.employee?['password'] ?? ''),
      'matricule': _matricule.text,
      'role': _role,
    };
    if (widget.employee == null) {
      await ApiService.createEmployee(body);
    } else {
      await ApiService.updateEmployee(widget.employee!['id'], body);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.employee == null ? 'Nouvel employé' : 'Modifier employé')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom complet')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
          TextField(controller: _matricule, decoration: const InputDecoration(labelText: 'Matricule')),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'ROLE_EMPLOYEE', child: Text('Employé')),
              DropdownMenuItem(value: 'ROLE_ADMIN', child: Text('Admin')),
            ],
            onChanged: (v) => setState(() => _role = v!),
            decoration: const InputDecoration(labelText: 'Rôle'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
        ]),
      ),
    );
  }
}