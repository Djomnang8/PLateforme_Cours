import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});
  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz disponibles')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return const Center(child: Text('Aucun quiz pour le moment'));
          }
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (_, i) {
              final q = quizzes[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(q['title'] ?? ''),
                  subtitle: Text('Score minimum: ${q['passingScore']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}