import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizFormScreen extends StatefulWidget {
  final Map<String, dynamic>? quiz;
  const QuizFormScreen({super.key, this.quiz});
  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _title = TextEditingController();
  final _passingScore = TextEditingController();
  final _courseId = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _title.text = widget.quiz!['title'] ?? '';
      _passingScore.text = widget.quiz!['passingScore']?.toString() ?? '';
      _courseId.text = widget.quiz!['course']?['id']?.toString() ?? '';
    }
  }

  Future<void> _save() async {
    final body = {
      'title': _title.text,
      'passingScore': int.tryParse(_passingScore.text) ?? 0,
      'courseId': int.tryParse(_courseId.text) ?? 0,  // envoi du courseId seul
    };
    if (widget.quiz == null) {
      await ApiService.createQuiz(body);
    } else {
      await ApiService.updateQuiz(widget.quiz!['id'], body);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz == null ? 'Nouveau quiz' : 'Modifier quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titre du quiz')),
            TextField(controller: _passingScore, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Score minimum')),
            TextField(controller: _courseId, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID du cours associé')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}