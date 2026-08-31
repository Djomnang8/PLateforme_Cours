import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizTakeScreen extends StatefulWidget {
  final int courseId;
  const QuizTakeScreen({super.key, required this.courseId});

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  late Future<Map<String, dynamic>> _future; // quiz + questions
  int _current = 0;
  List<int> _answers = [];

  @override
  void initState() {
    super.initState();
    _future = _loadQuiz();
  }

  Future<Map<String, dynamic>> _loadQuiz() async {
    // Supposons qu'on récupère le quiz associé au cours (à définir dans le backend)
    // Pour simplifier, on prend le premier quiz du cours. Le backend doit exposer /api/quizzes?courseId=...
    final quizzes = await ApiService.getQuizzes(); // Idéalement filtrer par courseId
    final quiz = quizzes.firstWhere((q) => q['course']['id'] == widget.courseId);
    final questions = await ApiService.getQuestions(quiz['id']);
    return {'quiz': quiz, 'questions': questions};
  }

  void _answer(int index) {
    setState(() {
      if (_answers.length <= _current) {
        _answers.add(index);
      } else {
        _answers[_current] = index;
      }
      if (_current < _answers.length - 1) {
        _current++;
      }
    });
  }

  Future<void> _submit() async {
    final data = await _loadQuiz();
    final questions = data['questions'] as List<dynamic>;
    // Remplir les réponses manquantes avec -1
    while (_answers.length < questions.length) {
      _answers.add(-1);
    }
    try {
      final result = await ApiService.submitQuiz(widget.courseId, _answers);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Résultat'),
          content: Text('Score: ${result['score']}%\n${result['passed'] ? "Réussi" : "Échoué"}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final questions = snapshot.data!['questions'] as List<dynamic>;
          if (questions.isEmpty) return const Center(child: Text('Aucune question'));
          final question = questions[_current];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Question ${_current + 1}/${questions.length}'),
                const SizedBox(height: 8),
                Text(question['text'] ?? '', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ...List.generate(question['options'].length, (i) {
                  return RadioListTile<int>(
                    title: Text(question['options'][i] ?? ''),
                    value: i,
                    groupValue: _current < _answers.length ? _answers[_current] : null,
                    onChanged: (val) => _answer(val!),
                  );
                }),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_current > 0)
                      ElevatedButton(
                        onPressed: () => setState(() => _current--),
                        child: const Text('Précédent'),
                      ),
                    ElevatedButton(
                      onPressed: _current == questions.length - 1 ? _submit : () => setState(() => _current++),
                      child: Text(_current == questions.length - 1 ? 'Soumettre' : 'Suivant'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}