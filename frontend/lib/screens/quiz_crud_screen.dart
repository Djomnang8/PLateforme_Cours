import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_form_screen.dart';

class QuizCRUDScreen extends StatefulWidget {
  const QuizCRUDScreen({super.key});
  @override
  State<QuizCRUDScreen> createState() => _QuizCRUDScreenState();
}

class _QuizCRUDScreenState extends State<QuizCRUDScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ApiService.getQuizzes();
    setState(() {});
  }

  void _delete(int id) async {
    await ApiService.deleteQuiz(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des quiz')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizFormScreen()));
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
          final quizzes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (_, i) {
              final q = quizzes[i];
              return Card(
                child: ListTile(
                  title: Text(q['title'] ?? ''),
                  subtitle: Text('Score min: ${q['passingScore']} (cours #${q['course']['id']})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuizFormScreen(quiz: q)),
                          );
                          _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(q['id']),
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