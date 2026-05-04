import 'package:flutter/material.dart';

class ModuleListScreen extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> Function() loader;
  final String Function(dynamic item) line1;
  final String Function(dynamic item)? line2;

  const ModuleListScreen({
    super.key,
    required this.title,
    required this.loader,
    required this.line1,
    this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<dynamic>>(
        future: loader(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Aucune donnée disponible'));
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) => Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(line1(data[i])),
                subtitle: line2 == null ? null : Text(line2!(data[i])),
              ),
            ),
          );
        },
      ),
    );
  }
}
