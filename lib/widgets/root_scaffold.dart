import 'package:beerculator/screens/calculate_page.dart';
import 'package:beerculator/screens/log_page.dart';
import 'package:flutter/material.dart';

class RootScaffold extends StatefulWidget {
  final double weight;
  final double height;

  const RootScaffold({super.key, required this.weight, required this.height});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalculatePage(weight: widget.weight, height: widget.height),
      const LogPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Calculate'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Log'),
        ],
      ),
    );
  }
}