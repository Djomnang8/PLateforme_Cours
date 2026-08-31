import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'pdf_viewer_screen.dart';
import 'quiz_take_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course['title'] ?? 'Cours')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Description: ${course['description'] ?? ''}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuizTakeScreen(courseId: course['id']),
              ));
            },
            child: const Text('Passer le quiz'),
          ),
          const Divider(),
          const Text('Documents', style: TextStyle(fontSize: 18)),
          FutureBuilder<List<dynamic>>(
            future: ApiService.getDocuments(course['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Text('Erreur: ${snapshot.error}');
              final docs = snapshot.data ?? [];
              return Column(
                children: docs.map((doc) => ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(doc['fileName'] ?? 'Document'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(
                        courseId: course['id'],
                        documentId: doc['id'],
                        documentName: doc['fileName'],
                      ),
                    ));
                  },
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}