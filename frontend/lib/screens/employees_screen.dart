import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'module_list_screen.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleListScreen(
      title: 'Gestion des employés (Admin)',
      loader: ApiService.getEmployees,
      line1: (u) => u['fullName']?.toString() ?? '-',
      line2: (u) => '${u['email'] ?? ''} • ${u['role'] ?? ''}',
    );
  }
}
