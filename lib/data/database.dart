import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Tabla de tareas (diseño de la Etapa 1).
/// id: entero autoincremental, identificador único de cada registro.
/// titulo: texto obligatorio, 1-200 caracteres.
/// completada: booleano, false por defecto.
@DataClassName('TareaRow')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  /// ETAPA 2 — se abre la base de verdad (sqlite3 nativo o sqlite3.wasm
  /// en web, según la plataforma) y se agregan las primeras operaciones
  /// reales: alta y consulta.
  AppDatabase() : super(_openConnection());

  /// Constructor para pruebas: inyecta un QueryExecutor en memoria.
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  /// F2: consulta reactiva de todas las tareas, ordenadas por id.
  /// Al ser un Stream, la UI se refresca sola después de cada escritura.
  Stream<List<TareaRow>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  /// F1: alta de una tarea nueva. Rechaza títulos vacíos o solo de
  /// espacios (P5): esto ya prueba que no es una lista en memoria, la
  /// fila queda escrita en SQLite y sobrevive a cerrar/abrir la app.
  Future<int> agregarTarea(String titulo) {
    final limpio = titulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: limpio));
  }

  // TODO (Etapa 3): actualizarTitulo(), actualizarCompletada() y
  // eliminarTarea().
}

/// Misma función de apertura para las 6 plataformas: sqlite3 nativo en
/// Android/iOS/desktop, y sqlite3.wasm + drift_worker en web (Etapa 4).
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'gestor_tareas_local',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
