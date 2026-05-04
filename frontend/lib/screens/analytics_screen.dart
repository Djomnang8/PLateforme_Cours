import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final stats = snapshot.data ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: stats.entries
                .map((e) => Card(child: ListTile(title: Text(e.key), trailing: Text('${e.value}'))))
                .toList(),
          );
        },
      ),
    );
  }
}
