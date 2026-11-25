import 'package:flutter/material.dart';
import 'data/database.dart';
import 'screens/tareas_page.dart';

void main() {
  runApp(GestorTareasApp(database: AppDatabase()));
}

/// Punto de entrada de la aplicación.
/// La base de datos SQLite (vía Drift) se crea una sola vez aquí y se
/// comparte con la pantalla principal.
class GestorTareasApp extends StatelessWidget {
  const GestorTareasApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(database: database),
    );
  }
}
