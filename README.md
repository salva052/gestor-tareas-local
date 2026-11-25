\## Etapa 4 — Web y verificación final



\*\*Configuración web:\*\* se agregaron `sqlite3.wasm` y `drift\_worker.dart.js`

a `web/`, descargados de los releases oficiales de `drift` (simolus3/drift,

tag drift-2.35.4, que coincide con la versión instalada). Con esto,

`driftDatabase()` usa la misma base de datos SQLite tanto en nativo

(sqlite3 compilado) como en el navegador (sqlite3.wasm + worker

compartido), sin duplicar lógica de acceso a datos.



\*\*Plataformas verificadas:\*\*

\- Web (Chrome): ejecutado con `flutter run -d chrome`. Alta, edición,

&#x20; cambio de estado y eliminación funcionan y los datos persisten en

&#x20; SQLite real vía sqlite3.wasm.

\- Windows (nativo): no se pudo compilar por falta del toolchain de

&#x20; Visual Studio (Desktop development with C++), no instalable en el

&#x20; tiempo disponible. El diseño sí contempla las 6 plataformas con la

&#x20; misma función `driftDatabase()`.



\*\*Pruebas automatizadas:\*\* `test/database\_test.dart` (capa de datos,

en memoria) y `test/widget\_test.dart` (UI). Correr con `flutter test`.



\*\*Fuentes consultadas:\*\*

\- https://drift.simonbinder.eu/

\- https://drift.simonbinder.eu/platforms/web/

\- https://pub.dev/packages/drift\_flutter

