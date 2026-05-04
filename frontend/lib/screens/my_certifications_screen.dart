import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyCertificationsScreen extends StatefulWidget {
  const MyCertificationsScreen({super.key});
  @override
  State<MyCertificationsScreen> createState() => _MyCertificationsScreenState();
}

class _MyCertificationsScreenState extends State<MyCertificationsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getMyCertifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes certifications')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final certs = snapshot.data ?? [];
          if (certs.isEmpty) {
            return const Center(child: Text('Aucune certification'));
          }
          return ListView.builder(
            itemCount: certs.length,
            itemBuilder: (_, i) {
              final c = certs[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.verified),
                  title: Text('Cours: ${c['course']['title'] ?? '?'}'),
                  subtitle: Text('Délivré le: ${c['issuedAt'] ?? ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}