import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';

// Pruebas de la capa de datos pura (sin UI), usando una base en memoria.
// Cubren persistencia real de alta/consulta, cambio de estado + eliminación
// y la validación de título vacío (equivalentes simplificados de P1, P2,
// P4 y P5 de la consigna).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('agregar una tarea la deja disponible en la consulta (P1 simplificado)',
      () async {
    await db.agregarTarea('Estudiar para el parcial');
    final tareas = await db.observarTareas().first;

    expect(tareas, hasLength(1));
    expect(tareas.first.titulo, 'Estudiar para el parcial');
    expect(tareas.first.completada, isFalse);
  });

  test('marcar como completada y luego eliminar (P2 y P4 simplificados)',
      () async {
    final id = await db.agregarTarea('Lavar el carro');
    await db.actualizarCompletada(id, true);

    var tareas = await db.observarTareas().first;
    expect(tareas.single.completada, isTrue);

    await db.eliminarTarea(id);
    tareas = await db.observarTareas().first;
    expect(tareas, isEmpty);
  });

  test('editar el título conserva el cambio (P3 simplificado)', () async {
    final id = await db.agregarTarea('Titulo original');
    await db.actualizarTitulo(id, 'Titulo editado');

    final tareas = await db.observarTareas().first;
    expect(tareas.single.titulo, 'Titulo editado');
  });

  test('rechaza título vacío o solo de espacios al agregar (P5)', () async {
    expect(() => db.agregarTarea('   '), throwsArgumentError);
  });
}
