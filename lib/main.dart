import 'package:beerculator/widgets/entrypoint.dart'; // The conditional entry screen logic
import 'package:flutter/material.dart';
import 'screens/log_page.dart';
import 'screens/calculate_page.dart';


/// The main entry point of the Beerculator app.
/// This sets up and runs the Flutter application.
void main() {
  runApp(const BeerculatorApp());
}

/// The root widget of the Beerculator app.
class BeerculatorApp extends StatelessWidget {
  const BeerculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beerculator',
      // Use the modern Material 3 design
      theme: ThemeData(useMaterial3: true),
      // The home widget will be determined dynamically in EntryPoint
      home: const RootScaffold(),
    );
  }
}


class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int index = 0;

  // TODO: later we’ll inject a repo here. For now, just pages.
  static const _pages = <Widget>[
    CalculatePage(),
    LogPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Calculate'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Log'),
        ],
      ),
    );
  }
}



