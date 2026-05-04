import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'analytics_screen.dart';
import 'employees_screen.dart';
import 'module_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  bool get _isAdmin => role.contains('ADMIN');
  bool get _isEmployee => role.contains('EMPLOYEE') || _isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plateforme de formation interne')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Rôle connecté'),
              subtitle: Text(role),
            ),
          ),
          const SizedBox(height: 8),
          _entry(
            context,
            icon: Icons.menu_book,
            title: 'CRUD Cours',
            subtitle: 'Créer, lire, modifier, supprimer des cours.',
            screen: ModuleListScreen(
              title: 'Gestion des cours',
              loader: ApiService.getCourses,
              line1: (c) => c['title']?.toString() ?? '-',
              line2: (c) => c['description']?.toString() ?? '',
            ),
          ),
          _entry(
            context,
            icon: Icons.quiz,
            title: 'CRUD Quiz',
            subtitle: 'Tests et scores de validation.',
            screen: ModuleListScreen(
              title: 'Gestion des quiz',
              loader: ApiService.getQuizzes,
              line1: (q) => q['title']?.toString() ?? '-',
              line2: (q) => 'Score minimum: ${q['passingScore'] ?? '-'}',
            ),
          ),
          _entry(
            context,
            icon: Icons.track_changes,
            title: 'Suivi progression',
            subtitle: 'Suivre/mettre à jour la progression des apprenants.',
            screen: ModuleListScreen(
              title: 'Progression',
              loader: ApiService.getProgress,
              line1: (p) => 'Apprenant #${p['learner']?['id'] ?? '-'}',
              line2: (p) => 'Cours #${p['course']?['id'] ?? '-'} • ${p['completionPercent'] ?? 0}%',
            ),
          ),
          _entry(
            context,
            icon: Icons.workspace_premium,
            title: 'Certifications',
            subtitle: 'Consulter et délivrer les certificats.',
            screen: ModuleListScreen(
              title: 'Certifications',
              loader: ApiService.getCertifications,
              line1: (c) => 'Apprenant #${c['learner']?['id'] ?? '-'}',
              line2: (c) => 'Cours #${c['course']?['id'] ?? '-'} • ${c['issuedAt'] ?? ''}',
            ),
          ),
          if (_isEmployee)
            _entry(
              context,
              icon: Icons.bar_chart,
              title: 'Analytics',
              subtitle: 'Statistiques globales et suivi des apprenants.',
              screen: const AnalyticsScreen(),
            ),
          if (_isAdmin)
            _entry(
              context,
              icon: Icons.admin_panel_settings,
              title: 'CRUD Employés (Admin)',
              subtitle: 'Gestion RBAC des comptes employés/admin.',
              screen: const EmployeesScreen(),
            ),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required Widget screen}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
