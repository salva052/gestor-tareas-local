import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Tabla de tareas. id autoincremental, título obligatorio (1-200
/// caracteres) y estado de completado con valor por defecto false.
@DataClassName('TareaRow')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  /// Base de datos real: se abre con sqlite3 nativo en Android/iOS/
  /// desktop y con sqlite3.wasm + drift_worker en web (ver _openConnection).
  AppDatabase() : super(_openConnection());

  /// Constructor solo para pruebas: permite inyectar un [QueryExecutor]
  /// en memoria (NativeDatabase.memory()) sin tocar el disco real.
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  /// F2: consulta reactiva de todas las tareas, ordenadas por id.
  /// Se expone como Stream para que la UI se actualice sola tras cada
  /// escritura, sin necesidad de volver a pedir los datos manualmente.
  Stream<List<TareaRow>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  /// F1: alta de una tarea. Rechaza títulos vacíos o solo de espacios (P5).
  Future<int> agregarTarea(String titulo) {
    final limpio = titulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: limpio));
  }

  /// F3: edición del título de una tarea existente.
  Future<bool> actualizarTitulo(int id, String nuevoTitulo) async {
    final limpio = nuevoTitulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    final filas = await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(titulo: Value(limpio)));
    return filas > 0;
  }

  /// F4: marcar como completada o pendiente.
  Future<bool> actualizarCompletada(int id, bool completada) async {
    final filas = await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(completada: Value(completada)));
    return filas > 0;
  }

  /// F5: eliminación por id.
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}

/// F7: misma función de apertura para las 6 plataformas. En nativo,
/// drift_flutter elige automáticamente una carpeta persistente adecuada
/// (vía path_provider). En web usa sqlite3.wasm + un worker compartido
/// para no bloquear el hilo principal.
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'gestor_tareas_local',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          // ignore: avoid_print
          print(
            'Drift web: usando ${result.chosenImplementation} por falta de '
            'soporte de ${result.missingFeatures} en este navegador.',
          );
        }
      },
    ),
  );
}
