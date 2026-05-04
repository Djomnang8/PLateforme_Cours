import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'employee_form_screen.dart';

class EmployeeCRUDScreen extends StatefulWidget {
  const EmployeeCRUDScreen({super.key});
  @override
  State<EmployeeCRUDScreen> createState() => _EmployeeCRUDScreenState();
}

class _EmployeeCRUDScreenState extends State<EmployeeCRUDScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ApiService.getEmployees();
    setState(() {});
  }

  void _delete(int id) async {
    await ApiService.deleteEmployee(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des employés')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeFormScreen()));
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
          final employees = snapshot.data ?? [];
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (_, i) {
              final e = employees[i];
              return Card(
                child: ListTile(
                  title: Text(e['fullName'] ?? ''),
                  subtitle: Text('${e['email']} - ${e['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: e)),
                          );
                          _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(e['id']),
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