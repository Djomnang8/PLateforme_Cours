import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgressListScreen extends StatefulWidget {
  const ProgressListScreen({super.key});
  @override
  State<ProgressListScreen> createState() => _ProgressListScreenState();
}

class _ProgressListScreenState extends State<ProgressListScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getProgress();
  }

  void _delete(int id) async {
    await ApiService.deleteProgress(id);
    setState(() => _future = ApiService.getProgress());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progression des apprenants')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return Card(
                child: ListTile(
                  title: Text('Apprenant #${p['learner']['id'] ?? '?'}'),
                  subtitle: Text('Cours #${p['course']['id']} - ${p['completionPercent']}%'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(p['id']),
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