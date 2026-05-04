import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_form_screen.dart';

class CourseCRUDScreen extends StatefulWidget {
  const CourseCRUDScreen({super.key});

  @override
  State<CourseCRUDScreen> createState() => _CourseCRUDScreenState();
}

class _CourseCRUDScreenState extends State<CourseCRUDScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ApiService.getCourses();
    setState(() {});
  }

  void _delete(int id) async {
    try {
      await ApiService.deleteCourse(id);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des cours')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseFormScreen()),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final courses = snapshot.data ?? [];
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (_, i) {
              final c = courses[i];
              return Card(
                child: ListTile(
                  title: Text(c['title'] ?? ''),
                  subtitle: Text(c['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseFormScreen(course: c),
                            ),
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