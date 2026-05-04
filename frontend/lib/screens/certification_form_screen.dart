import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CertificationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? cert;
  const CertificationFormScreen({super.key, this.cert});
  @override
  State<CertificationFormScreen> createState() => _CertificationFormScreenState();
}

class _CertificationFormScreenState extends State<CertificationFormScreen> {
  final _learnerId = TextEditingController();
  final _courseId = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.cert != null) {
      _learnerId.text = widget.cert!['learner']?['id']?.toString() ?? '';
      _courseId.text = widget.cert!['course']?['id']?.toString() ?? '';
      _date = DateTime.tryParse(widget.cert!['issuedAt'] ?? '') ?? DateTime.now();
    }
  }

  Future<void> _save() async {
    final body = {
      'learnerId': int.tryParse(_learnerId.text) ?? 0,
      'courseId': int.tryParse(_courseId.text) ?? 0,
      'issuedAt': _date.toIso8601String().substring(0, 10),
    };
    if (widget.cert == null) {
      await ApiService.createCertification(body);
    } else {
      await ApiService.updateCertification(widget.cert!['id'], body);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cert == null ? 'Nouvelle certification' : 'Modifier certification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _learnerId, decoration: const InputDecoration(labelText: 'ID Apprenant')),
          TextField(controller: _courseId, decoration: const InputDecoration(labelText: 'ID Cours')),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Date : '),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text('${_date.toLocal()}'.split(' ')[0]),
            ),
          ]),
          ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
        ]),
      ),
    );
  }
}