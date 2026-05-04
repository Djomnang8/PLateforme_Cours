import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plateforme de formation interne')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(title: const Text('Rôle connecté'), subtitle: Text(role))),
          const Card(child: ListTile(title: Text('Module CRUD #1'), subtitle: Text('Gestion des cours'))),
          const Card(child: ListTile(title: Text('Module CRUD #2'), subtitle: Text('Gestion des quiz'))),
          const Card(child: ListTile(title: Text('Suivi progression'), subtitle: Text('Mise à jour progression apprenant'))),
          const Card(child: ListTile(title: Text('Certifications'), subtitle: Text('Génération et consultation des certificats'))),
          const Card(child: ListTile(title: Text('Analytics'), subtitle: Text('Statistiques globales et suivi apprenants'))),
          const Card(child: ListTile(title: Text('Gestion progression (module manquant ajouté)'), subtitle: Text('CRUD progression par cours et apprenant'))),
          const Card(child: ListTile(title: Text('Gestion certifications (module manquant ajouté)'), subtitle: Text('CRUD certificats + délivrance'))),
        ],
      ),
    );
  }
}
