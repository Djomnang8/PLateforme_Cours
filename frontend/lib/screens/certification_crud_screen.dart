import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'certification_form_screen.dart';

class CertificationCRUDScreen extends StatefulWidget {
  const CertificationCRUDScreen({super.key});
  @override
  State<CertificationCRUDScreen> createState() => _CertificationCRUDScreenState();
}

class _CertificationCRUDScreenState extends State<CertificationCRUDScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ApiService.getCertifications();
    setState(() {});
  }

  void _delete(int id) async {
    await ApiService.deleteCertification(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des certifications')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificationFormScreen()));
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final certs = snapshot.data ?? [];
          return ListView.builder(
            itemCount: certs.length,
            itemBuilder: (_, i) {
              final c = certs[i];
              return Card(
                child: ListTile(
                  title: Text('Apprenant #${c['learner']['id']}'),
                  subtitle: Text('Cours #${c['course']['id']} - ${c['issuedAt']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CertificationFormScreen(cert: c)),
                          );
                          _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(c['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}