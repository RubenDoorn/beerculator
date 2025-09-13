import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final List<String> _entries = [];

  void _addEntry() {
    setState(() {
      _entries.add("Workout ${_entries.length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _entries.isEmpty
          ? const Center(child: Text("No workouts logged yet"))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, i) => ListTile(title: Text(_entries[i])),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
