import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourseFormScreen extends StatefulWidget {
  final Map<String, dynamic>? course;
  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!['title'] ?? '';
      _descController.text = widget.course!['description'] ?? '';
      _active = widget.course!['active'] ?? true;
    }
  }

  Future<void> _save() async {
    final body = {
      'title': _titleController.text,
      'description': _descController.text,
      'active': _active,
    };
    if (widget.course == null) {
      await ApiService.createCourse(body);
    } else {
      await ApiService.updateCourse(widget.course!['id'], body);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Nouveau cours' : 'Modifier cours'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            SwitchListTile(
              title: const Text('Actif'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}