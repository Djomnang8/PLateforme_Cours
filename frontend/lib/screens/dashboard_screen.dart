import 'package:flutter/material.dart';
import 'my_courses_screen.dart';
import 'quiz_list_screen.dart';
import 'my_certifications_screen.dart';
import 'course_crud_screen.dart';
import 'quiz_crud_screen.dart';
import 'progress_list_screen.dart';
import 'certification_crud_screen.dart';
import 'employee_crud_screen.dart';
import 'analytics_screen.dart';
import 'login_screen.dart';
import '../services/user_session.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  bool get _isAdmin => role.contains('ADMIN');
  bool get _isEmployee => role.contains('EMPLOYEE') || _isAdmin;
  bool get _isLearner => role.contains('LEARNER');

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
              title: const Text('Rôle'),
              subtitle: Text(role),
            ),
          ),
          const SizedBox(height: 8),
          if (_isLearner) ...[
            _entry(context, icon: Icons.school, title: 'Mes cours',
                subtitle: 'Voir et mettre à jour ma progression',
                screen: const MyCoursesScreen()),
            _entry(context, icon: Icons.quiz, title: 'Tests',
                subtitle: 'Répondre aux quiz',
                screen: const QuizListScreen()),
            _entry(context, icon: Icons.workspace_premium, title: 'Mes certifications',
                subtitle: 'Consulter mes certificats',
                screen: const MyCertificationsScreen()),
          ],
          if (_isEmployee) ...[
            _entry(context, icon: Icons.menu_book, title: 'Gestion des cours',
                subtitle: 'Créer, modifier, supprimer des cours',
                screen: const CourseCRUDScreen()),
            _entry(context, icon: Icons.quiz, title: 'Gestion des quiz',
                subtitle: 'Créer, modifier, supprimer des quiz',
                screen: const QuizCRUDScreen()),
            _entry(context, icon: Icons.track_changes, title: 'Suivi progression',
                subtitle: 'Visualiser la progression des apprenants',
                screen: const ProgressListScreen()),
            _entry(context, icon: Icons.workspace_premium, title: 'Certifications',
                subtitle: 'Délivrer et gérer les certificats',
                screen: const CertificationCRUDScreen()),
            _entry(context, icon: Icons.bar_chart, title: 'Analytics',
                subtitle: 'Statistiques globales',
                screen: const AnalyticsScreen()),
          ],
          if (_isAdmin) ...[
            _entry(context, icon: Icons.admin_panel_settings, title: 'Gestion des employés',
                subtitle: 'CRUD des comptes employés/admin',
                screen: const EmployeeCRUDScreen()),
          ],
          ElevatedButton(
            onPressed: () {
              UserSession.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Déconnexion'),
          )
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