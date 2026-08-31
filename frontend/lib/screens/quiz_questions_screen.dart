import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const QuizQuestionsScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late Future<List<dynamic>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _questionsFuture = ApiService.getQuestions(widget.quiz['id']);
    setState(() {});
  }

  void _deleteQuestion(int id) async {
    await ApiService.deleteQuestion(widget.quiz['id'], id);
    _load();
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (_) => QuestionFormDialog(
        quizId: widget.quiz['id'],
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Questions: ${widget.quiz['title']}')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Text('Erreur: ${snapshot.error}');
          final questions = snapshot.data ?? [];
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (_, i) {
              final q = questions[i];
              return Card(
                child: ListTile(
                  title: Text(q['text'] ?? ''),
                  subtitle: Text('Options: ${q['options'].join(", ")} | Correcte: ${q['correctIndex']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => QuestionFormDialog(
                              quizId: widget.quiz['id'],
                              question: q,
                              onSaved: _load,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteQuestion(q['id']),
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

class QuestionFormDialog extends StatefulWidget {
  final int quizId;
  final Map<String, dynamic>? question;
  final VoidCallback onSaved;
  const QuestionFormDialog({super.key, required this.quizId, this.question, required this.onSaved});

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _textCtrl = TextEditingController();
  final List<TextEditingController> _optionsCtrls = [];
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _textCtrl.text = widget.question!['text'] ?? '';
      final opts = List<String>.from(widget.question!['options'] ?? []);
      for (var opt in opts) {
        _optionsCtrls.add(TextEditingController(text: opt));
      }
      _correctIndex = widget.question!['correctIndex'] ?? 0;
    } else {
      _optionsCtrls.add(TextEditingController());
      _optionsCtrls.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Nouvelle question' : 'Modifier question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _textCtrl, decoration: const InputDecoration(labelText: 'Texte de la question')),
            const SizedBox(height: 8),
            ..._optionsCtrls.asMap().entries.map((entry) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: 'Option ${entry.key + 1}'),
                    ),
                  ),
                  Radio<int>(
                    value: entry.key,
                    groupValue: _correctIndex,
                    onChanged: (v) => setState(() => _correctIndex = v!),
                  ),
                ],
              );
            }),
            TextButton(
              onPressed: () {
                setState(() {
                  _optionsCtrls.add(TextEditingController());
                });
              },
              child: const Text('Ajouter une option'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final body = {
              'text': _textCtrl.text,
              'options': _optionsCtrls.map((c) => c.text).toList(),
              'correctIndex': _correctIndex,
            };
            if (widget.question == null) {
              await ApiService.createQuestion(widget.quizId, body);
            } else {
              await ApiService.updateQuestion(widget.quizId, widget.question!['id'], body);
            }
            widget.onSaved();
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}