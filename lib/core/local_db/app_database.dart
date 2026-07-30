import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Generic key-value cache for "last known good" server responses (today's
/// meals, the active goal, recent weight logs). `payload` is the raw JSON
/// the server returned, not a parsed model - callers decode it with the
/// same response-to-model mapping they use for the live path (see
/// lib/core/local_db/cached_fetch.dart), so there is no second copy of that
/// mapping to keep in sync.
class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'nutriflow_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
