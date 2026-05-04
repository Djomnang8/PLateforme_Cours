import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});
  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  late Future<List<dynamic>> _coursesFuture;
  late Future<List<dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _coursesFuture = ApiService.getCourses();
    _progressFuture = ApiService.getMyProgress();
    setState(() {});
  }

  void _updateProgress(int courseId, int percent) async {
    try {
      await ApiService.updateMyProgress(courseId, percent);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progression mise à jour')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showPercentDialog(int courseId, int current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Progression (%)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Pourcentage'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 0;
              _updateProgress(courseId, val.clamp(0, 100));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      body: FutureBuilder(
        future: Future.wait([_coursesFuture, _progressFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final courses = (snapshot.data as List<dynamic>)[0] as List<dynamic>;
          final progressList = (snapshot.data as List<dynamic>)[1] as List<dynamic>;

          if (courses.isEmpty) {
            return const Center(child: Text('Aucun cours disponible'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final prog = progressList.firstWhere(
                (p) => p['course']['id'] == course['id'],
                orElse: () => null,
              );
              final percent = prog?['completionPercent'] ?? 0;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(course['title'] ?? 'Sans titre'),
                  subtitle: Text('Progression: $percent%'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showPercentDialog(course['id'], percent),
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