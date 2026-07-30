# Weight logs + local read cache Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** add a body-weight logging feature (`weight_logs`, direct-Supabase CRUD) and a local read-through cache (Drift/SQLite) that both the new weight history and the existing dashboard (today's meals, goal) fall back to when the network is unavailable.

**Architecture:** a single generic key-value cache table (`CacheEntries`: key, JSON payload, fetchedAt) backed by Drift/SQLite, wrapped by a small `LocalCache` interface. A shared `cachedFetch` helper implements "try network, cache the raw JSON on success, decode-from-cache on failure" once, reused by `MealLogsRepository`, `goalProvider`, and the new `WeightLogsRepository`. Weight logs themselves are plain direct-Supabase CRUD (insert/select on `weight_logs`), matching the existing `meal_logs` pattern, with the app's internal user id resolved via the `app_user_id()` RPC (no REST endpoint involved, per CLAUDE.md section 6).

**Tech Stack:** Flutter/Dart, Riverpod, `supabase_flutter` (direct CRUD), `drift` + `sqlite3_flutter_libs` + `path_provider` + `path` (local cache), `uuid` (client-generated ids), `freezed` (models), `flutter_test` (unit tests).

**Design spec:** `docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md` (approved).

## Global Constraints

- UI text in Spanish; code, identifiers, and comments in English (CLAUDE.md section 5).
- Never use the em dash character in any text this plan produces (UI copy, comments, commit messages) - use a comma, colon, or a new sentence instead (CLAUDE.md section 5 / user global style rule).
- Never use `dynamic` except at the JSON-deserialization boundary (CLAUDE.md section 9).
- Never swallow an error with an empty `catch`; every error is logged with context (`debugPrint(...)`) or propagated (CLAUDE.md section 9).
- Simple CRUD (`weight_logs`, like `meal_logs`) goes through direct Supabase access relying on RLS/`app_user_id()`, never through a new REST endpoint (CLAUDE.md section 6).
- Never reimplement server-side business/numeric logic client-side (CLAUDE.md section 2). Weight logging has no such logic to reimplement (no BMI/trend computation exists anywhere yet, per the design spec).
- Postgres `numeric`/`decimal` columns arrive from PostgREST as JSON strings, not numbers - always accept either shape (CLAUDE.md 2026-07-17 bitacora entry).
- Icons come from `lucide_icons_flutter` (`LucideIcons.*`) only, never `Icons.*` (CLAUDE.md section 5).
- Flutter SDK constraint stays `^3.12.1` (`pubspec.yaml`); do not downgrade `freezed` (`^3.0.0`), `flutter_riverpod`/`riverpod_annotation` (`^3.3.2`/`^4.0.3`), or `go_router` (`^17.3.0`).
- This cache is read-only (no offline write queue) - logging a meal or a weight still requires a live connection in this scope.

---

## Task 1: Add local-cache and weight-logging dependencies

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `uuid` available as regular dependencies; `drift_dev` available as a dev dependency, for every later task in this plan.

- [ ] **Step 1: Add the runtime dependencies**

Run:
```
flutter pub add drift sqlite3_flutter_libs path_provider path uuid
```

- [ ] **Step 2: Add the codegen dev dependency**

Run:
```
flutter pub add -d drift_dev
```

- [ ] **Step 3: Verify resolution**

Run: `flutter pub get`
Expected: completes with no version conflicts. Open `pubspec.yaml` and confirm `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `uuid` are under `dependencies` and `drift_dev` is under `dev_dependencies`.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add drift/sqlite and uuid dependencies for local cache and weight logs"
```

---

## Task 2: Shared PostgREST numeric helper (TDD)

**Files:**
- Create: `lib/core/supabase/postgrest_numeric.dart`
- Test: `test/postgrest_numeric_test.dart`
- Modify: `lib/core/supabase/meal_logs_repository.dart:56-61` (remove the private `_asNum` method, use the shared helper instead)

**Interfaces:**
- Produces: `num numFromPostgrest(Object? value)` in `lib/core/supabase/postgrest_numeric.dart`, used by `MealLogsRepository` (this task) and `WeightLogsRepository` (Task 7).

- [ ] **Step 1: Write the failing test**

Create `test/postgrest_numeric_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/postgrest_numeric.dart';

void main() {
  group('numFromPostgrest', () {
    test('parses a JSON string as returned for numeric/decimal columns', () {
      expect(numFromPostgrest('12.50'), 12.5);
    });

    test('passes a JSON number through unchanged', () {
      expect(numFromPostgrest(7), 7);
    });

    test('throws on null (callers must handle optional columns before calling this)', () {
      expect(() => numFromPostgrest(null), throwsA(isA<TypeError>()));
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/postgrest_numeric_test.dart`
Expected: FAIL (compile error, `package:nutriflow_mobile/core/supabase/postgrest_numeric.dart` does not exist yet).

- [ ] **Step 3: Write the implementation**

Create `lib/core/supabase/postgrest_numeric.dart`:
```dart
/// PostgREST serializes Postgres `numeric`/`decimal` columns as JSON
/// strings (not numbers) to avoid float precision loss, so any column of
/// that Postgres type read via direct Supabase access must accept either
/// shape (see CLAUDE.md's 2026-07-17 bitacora entry for the incident this
/// fixed).
num numFromPostgrest(Object? value) => value is String ? num.parse(value) : value as num;
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/postgrest_numeric_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Use the shared helper in `MealLogsRepository`**

In `lib/core/supabase/meal_logs_repository.dart`, add the import:
```dart
import 'postgrest_numeric.dart';
```
Replace every call to `_asNum(...)` inside `fetchTodayEntries` with `numFromPostgrest(...)`, and delete the now-unused private method and its doc comment (lines 56-61):
```dart
  num _asNum(Object? value) => value is String ? num.parse(value) : value as num;
```

- [ ] **Step 6: Verify the existing repository still analyzes cleanly**

Run: `flutter analyze lib/core/supabase/meal_logs_repository.dart`
Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add lib/core/supabase/postgrest_numeric.dart lib/core/supabase/meal_logs_repository.dart test/postgrest_numeric_test.dart
git commit -m "refactor: extract numFromPostgrest helper, reuse it in MealLogsRepository"
```

---

## Task 3: Local cache infrastructure (Drift-backed)

**Files:**
- Create: `lib/core/local_db/cached_value.dart`
- Create: `lib/core/local_db/local_cache.dart`
- Create: `lib/core/local_db/app_database.dart`
- Create: `lib/core/local_db/drift_local_cache.dart`
- Create: `lib/core/local_db/providers.dart`
- Generated (by build_runner, do not hand-write): `lib/core/local_db/app_database.g.dart`

**Interfaces:**
- Produces: `class CachedValue<T> { T value; bool fromCache; }`, `abstract class LocalCache { Future<void> putCache(String key, Object? jsonEncodable); Future<Object?> getCache(String key); }`, `class DriftLocalCache implements LocalCache`, `class AppDatabase`, `final appDatabaseProvider = Provider<AppDatabase>`, `final localCacheProvider = Provider<LocalCache>`.
- Consumed by: Task 4 (`cachedFetch`), Task 5/6/7/8 (repositories and providers).

This task's deliverable is verified statically (analyze + codegen succeed) rather than with a runtime unit test: `LocalCache`'s actual behavior (put/get roundtrip, fallback-on-failure) is exercised by Task 4's `cachedFetch` tests against a fake implementation, and the real Drift-backed path is exercised end to end by the manual device check in Task 10. Running a real SQLite engine inside plain `flutter test` on this Windows dev machine is not reliably available without a native `sqlite3` library on the host, which is why the interface/fake split from the design spec exists.

- [ ] **Step 1: Write the `CachedValue` wrapper**

Create `lib/core/local_db/cached_value.dart`:
```dart
/// Wraps a value fetched via [cachedFetch] with whether it came from the
/// network just now (`fromCache: false`) or from [LocalCache] because the
/// network call failed (`fromCache: true`). UI reads this to show a
/// non-blocking "offline, showing saved data" notice instead of a hard
/// error (see docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md).
class CachedValue<T> {
  const CachedValue(this.value, {required this.fromCache});

  final T value;
  final bool fromCache;
}
```

- [ ] **Step 2: Write the `LocalCache` interface**

Create `lib/core/local_db/local_cache.dart`:
```dart
/// Read-through JSON cache keyed by a caller-chosen string (e.g.
/// 'today_meals', 'goal', 'weight_logs_recent'). Kept as an interface,
/// separate from [DriftLocalCache], so repository/provider logic can be
/// unit-tested against a fake without a real SQLite database - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
abstract class LocalCache {
  Future<void> putCache(String key, Object? jsonEncodable);

  /// Returns the last value stored under [key] (JSON-decoded), or null if
  /// nothing has been cached for it yet.
  Future<Object?> getCache(String key);
}
```

- [ ] **Step 3: Write the Drift database**

Create `lib/core/local_db/app_database.dart`:
```dart
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
```

- [ ] **Step 4: Generate the Drift code**

Run:
```
dart run build_runner build --delete-conflicting-outputs
```
Expected: completes with 0 errors and creates `lib/core/local_db/app_database.g.dart`.

- [ ] **Step 5: Write the Drift-backed `LocalCache` implementation**

Create `lib/core/local_db/drift_local_cache.dart`:
```dart
import 'dart:convert';

import 'app_database.dart';
import 'local_cache.dart';

class DriftLocalCache implements LocalCache {
  DriftLocalCache(this._db);

  final AppDatabase _db;

  @override
  Future<void> putCache(String key, Object? jsonEncodable) {
    return _db.into(_db.cacheEntries).insertOnConflictUpdate(
          CacheEntriesCompanion.insert(
            key: key,
            payload: jsonEncode(jsonEncodable),
            fetchedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<Object?> getCache(String key) async {
    final row = await (_db.select(_db.cacheEntries)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.payload);
  }
}
```

- [ ] **Step 6: Wire the Riverpod providers**

Create `lib/core/local_db/providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'drift_local_cache.dart';
import 'local_cache.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localCacheProvider = Provider<LocalCache>((ref) {
  return DriftLocalCache(ref.watch(appDatabaseProvider));
});
```

- [ ] **Step 7: Verify**

Run: `flutter analyze lib/core/local_db`
Expected: 0 issues.

- [ ] **Step 8: Commit**

```bash
git add lib/core/local_db pubspec.yaml pubspec.lock
git commit -m "feat: add Drift-backed local cache infrastructure"
```

---

## Task 4: `cachedFetch` helper (TDD)

**Files:**
- Create: `lib/core/local_db/cached_fetch.dart`
- Test: `test/cached_fetch_test.dart`

**Interfaces:**
- Consumes: `LocalCache` (`putCache`, `getCache`) and `CachedValue<T>` from Task 3.
- Produces: `Future<CachedValue<T>> cachedFetch<T>({required LocalCache cache, required String key, required Future<Object?> Function() fetchRaw, required T Function(Object? raw) decode, void Function(Object error, StackTrace stackTrace)? onNetworkError})`, re-exporting `CachedValue` (so importing `cached_fetch.dart` is enough to get both). Consumed by Task 5 (`MealLogsRepository`), Task 6 (`goalProvider`), Task 7 (`WeightLogsRepository`).

- [ ] **Step 1: Write the failing tests**

Create `test/cached_fetch_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/local_db/cached_fetch.dart';
import 'package:nutriflow_mobile/core/local_db/local_cache.dart';

class _FakeLocalCache implements LocalCache {
  final Map<String, Object?> _store = {};

  @override
  Future<void> putCache(String key, Object? jsonEncodable) async {
    _store[key] = jsonEncodable;
  }

  @override
  Future<Object?> getCache(String key) async => _store[key];
}

void main() {
  group('cachedFetch', () {
    test('caches and returns the network value on success', () async {
      final cache = _FakeLocalCache();

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => 41,
        decode: (raw) => (raw as int) + 1,
      );

      expect(result.value, 42);
      expect(result.fromCache, isFalse);
      expect(await cache.getCache('k'), 41);
    });

    test('falls back to the cached value when the network call throws', () async {
      final cache = _FakeLocalCache();
      await cache.putCache('k', 41);

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => throw Exception('network down'),
        decode: (raw) => (raw as int) + 1,
      );

      expect(result.value, 42);
      expect(result.fromCache, isTrue);
    });

    test('rethrows when the network call throws and nothing is cached', () async {
      final cache = _FakeLocalCache();

      expect(
        () => cachedFetch<int>(
          cache: cache,
          key: 'missing',
          fetchRaw: () async => throw Exception('network down'),
          decode: (raw) => raw as int,
        ),
        throwsException,
      );
    });

    test('calls onNetworkError with the original error before falling back', () async {
      final cache = _FakeLocalCache();
      await cache.putCache('k', 1);
      Object? seenError;

      await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => throw StateError('boom'),
        decode: (raw) => raw as int,
        onNetworkError: (error, stackTrace) => seenError = error,
      );

      expect(seenError, isA<StateError>());
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/cached_fetch_test.dart`
Expected: FAIL (compile error, `cached_fetch.dart` does not exist yet).

- [ ] **Step 3: Write the implementation**

Create `lib/core/local_db/cached_fetch.dart`:
```dart
import 'cached_value.dart';
import 'local_cache.dart';

export 'cached_value.dart';

/// Fetches [key] over the network via [fetchRaw], caches the raw JSON-safe
/// result in [cache], and decodes it with [decode] - reusing the exact same
/// decode step whether the data just came from the network or, on failure,
/// from [cache]. Rethrows if the network call fails AND nothing has been
/// cached for [key] yet.
Future<CachedValue<T>> cachedFetch<T>({
  required LocalCache cache,
  required String key,
  required Future<Object?> Function() fetchRaw,
  required T Function(Object? raw) decode,
  void Function(Object error, StackTrace stackTrace)? onNetworkError,
}) async {
  try {
    final raw = await fetchRaw();
    await cache.putCache(key, raw);
    return CachedValue(decode(raw), fromCache: false);
  } catch (error, stackTrace) {
    onNetworkError?.call(error, stackTrace);
    final cached = await cache.getCache(key);
    if (cached != null) {
      return CachedValue(decode(cached), fromCache: true);
    }
    rethrow;
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/cached_fetch_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/local_db/cached_fetch.dart test/cached_fetch_test.dart
git commit -m "feat: add cachedFetch, the shared network-then-cache-fallback helper"
```

---

## Task 5: Retrofit `MealLogsRepository` with the local cache

**Files:**
- Modify: `lib/core/supabase/meal_logs_repository.dart` (full rewrite of the class body)
- Modify: `lib/core/supabase/providers.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart:85-112` (unwrap `CachedValue`)

**Interfaces:**
- Consumes: `cachedFetch`, `CachedValue<T>` (Task 4), `LocalCache`/`localCacheProvider` (Task 3), `numFromPostgrest` (Task 2).
- Produces: `MealLogsRepository(LocalCache cache)` with `Future<CachedValue<List<DayMealEntry>>> fetchTodayEntries()`; `final todayMealEntriesProvider = FutureProvider<CachedValue<List<DayMealEntry>>>` (type change from Task 5 onward - Task 6 and the dashboard both depend on this new type).

- [ ] **Step 1: Rewrite `MealLogsRepository`**

Replace the full contents of `lib/core/supabase/meal_logs_repository.dart` with:
```dart
import 'package:flutter/foundation.dart';

import '../../models/day_meal_entry.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'postgrest_numeric.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase reads for `meal_logs`/`meal_items` (CLAUDE.md section 6 -
/// CRUD reads bypass the Fase 1 REST API and rely on RLS/`app_user_id()`
/// for per-user filtering, so no `user_id` filter is added here), read
/// through the local cache (docs/superpowers/specs/2026-07-30-weight-logs-
/// local-cache-design.md) so today's meals still show if the network call
/// fails.
class MealLogsRepository {
  MealLogsRepository(this._cache);

  final LocalCache _cache;

  static const _cacheKey = 'today_meals';

  /// Today's logged meal items (local device day), newest first. Mirrors
  /// `getDayEntries` in `nutriflow/src/repositories/meal-logs.repo.ts`:
  /// same join (meal_items -> meal_logs -> foods), same
  /// `deleted_at is null` + `logged_at` day-range filters.
  Future<CachedValue<List<DayMealEntry>>> fetchTodayEntries() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return cachedFetch<List<DayMealEntry>>(
      cache: _cache,
      key: _cacheKey,
      fetchRaw: () => supabase
          .from('meal_items')
          .select('''
            id,
            meal_log_id,
            quantity_grams,
            calories_snapshot,
            protein_snapshot,
            carbs_snapshot,
            fat_snapshot,
            foods(name_es),
            meal_logs!inner(meal_type, logged_at)
          ''')
          .isFilter('deleted_at', null)
          .isFilter('meal_logs.deleted_at', null)
          .gte('meal_logs.logged_at', dayStart.toIso8601String())
          .lt('meal_logs.logged_at', dayEnd.toIso8601String())
          .order('logged_at', referencedTable: 'meal_logs', ascending: false),
      decode: (raw) => (raw as List).cast<Map<String, dynamic>>().map(_toEntry).toList(),
      onNetworkError: (error, stackTrace) =>
          debugPrint('fetchTodayEntries failed, falling back to cache: $error\n$stackTrace'),
    );
  }

  DayMealEntry _toEntry(Map<String, dynamic> row) {
    final mealLog = row['meal_logs'] as Map<String, dynamic>;
    final food = row['foods'] as Map<String, dynamic>?;
    return DayMealEntry(
      mealItemId: row['id'] as String,
      mealLogId: row['meal_log_id'] as String,
      foodName: food?['name_es'] as String? ?? 'Alimento',
      mealType: mealLog['meal_type'] as String,
      quantityGrams: numFromPostgrest(row['quantity_grams']),
      calories: numFromPostgrest(row['calories_snapshot']),
      protein: numFromPostgrest(row['protein_snapshot']),
      carbs: numFromPostgrest(row['carbs_snapshot']),
      fat: numFromPostgrest(row['fat_snapshot']),
      loggedAt: DateTime.parse(mealLog['logged_at'] as String),
    );
  }
}
```

- [ ] **Step 2: Update `mealLogsRepositoryProvider` and `todayMealEntriesProvider`**

In `lib/core/supabase/providers.dart`, replace the whole file with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/day_macro_totals.dart';
import '../../models/day_meal_entry.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/providers.dart';
import 'meal_logs_repository.dart';

final mealLogsRepositoryProvider = Provider<MealLogsRepository>((ref) {
  return MealLogsRepository(ref.watch(localCacheProvider));
});

final todayMealEntriesProvider = FutureProvider<CachedValue<List<DayMealEntry>>>((ref) {
  return ref.watch(mealLogsRepositoryProvider).fetchTodayEntries();
});

/// Derived from [todayMealEntriesProvider] rather than a second query -
/// there's no Postgres view/RPC for daily totals yet (see CLAUDE.md
/// 2026-07-16 audit), so summing the same rows client-side avoids a
/// redundant round trip.
final todayMacroTotalsProvider = Provider<AsyncValue<DayMacroTotals>>((ref) {
  final entries = ref.watch(todayMealEntriesProvider);
  return entries.whenData((cached) {
    return cached.value.fold(DayMacroTotals.zero(), (totals, entry) => totals + entry);
  });
});
```
(Weight logs providers are added here in Task 8, not this step.)

- [ ] **Step 3: Unwrap `CachedValue` in the dashboard's meal list**

In `lib/features/dashboard/dashboard_screen.dart`, replace the `entries.when(...)` block (lines 85-112) with:
```dart
                  ...entries.when(
                    data: (cached) => cached.value.isEmpty
                        ? [
                            Text(
                              'Todavia no registras comidas hoy.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: semantics.mutedForeground,
                              ),
                            ),
                          ]
                        : [
                            for (final (index, entry) in cached.value.indexed) ...[
                              if (index > 0) const SizedBox(height: 10),
                              _MealRow(
                                icon: iconForMealType(entry.mealType),
                                title: labelForMealType(entry.mealType),
                                subtitle: '${entry.foodName} - ${entry.calories.round()} kcal',
                              ),
                            ],
                          ],
                    loading: () => [const Center(child: CircularProgressIndicator())],
                    error: (error, _) => [
                      Text(
                        'No se pudieron cargar las comidas de hoy.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                      ),
                    ],
                  ),
```

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/core/supabase lib/features/dashboard`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/core/supabase/meal_logs_repository.dart lib/core/supabase/providers.dart lib/features/dashboard/dashboard_screen.dart
git commit -m "feat: read today's meals through the local cache with a fallback path"
```

---

## Task 6: Retrofit `goalProvider` with the local cache, add the offline banner

**Files:**
- Modify: `lib/core/api/providers.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart:138-259` (`_TodaySummaryCard`)

**Interfaces:**
- Consumes: `cachedFetch`, `CachedValue<T>` (Task 4), `localCacheProvider` (Task 3), `MacroGoal.toJson()`/`.fromJson()` (already generated, `lib/models/macro_goal.dart`).
- Produces: `final goalProvider = FutureProvider<CachedValue<MacroGoal>>` (type change - any future consumer of `goalProvider` must unwrap `.value`).

- [ ] **Step 1: Rewrite `goalProvider`**

Replace the contents of `lib/core/api/providers.dart` with:
```dart
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/macro_goal.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/providers.dart';
import 'api_client.dart';
import 'nutriflow_api.dart';

/// Set once in main() after ClerkAuthState is created, before runApp -
/// every other provider that needs auth or the API client reads through
/// this rather than each constructing its own ClerkAuthState.
final clerkAuthProvider = Provider<ClerkAuthState>((ref) {
  throw UnimplementedError('clerkAuthProvider must be overridden in main()');
});

final nutriFlowApiProvider = Provider<NutriFlowApi>((ref) {
  final clerkAuth = ref.watch(clerkAuthProvider);
  return NutriFlowApi(buildApiClient(clerkAuth));
});

/// GET /api/goals - server-side logic (falls back to a default when the
/// user has none), so this goes through the REST client, not Supabase
/// direct (CLAUDE.md section 6). Read through the local cache
/// (docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md)
/// so the dashboard still shows the last known goal if the request fails.
final goalProvider = FutureProvider<CachedValue<MacroGoal>>((ref) {
  final cache = ref.watch(localCacheProvider);
  return cachedFetch<MacroGoal>(
    cache: cache,
    key: 'goal',
    fetchRaw: () async => (await ref.watch(nutriFlowApiProvider).getGoal()).toJson(),
    decode: (raw) => MacroGoal.fromJson(raw as Map<String, dynamic>),
    onNetworkError: (error, stackTrace) =>
        debugPrint('getGoal failed, falling back to cache: $error\n$stackTrace'),
  );
});

/// GET /api/onboarding/status - drives the auth gate (`app/router.dart`).
/// Autodispose + kept outside `goalProvider` since it's only read once per
/// sign-in, not part of the dashboard's data.
final onboardingStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(nutriFlowApiProvider).getOnboardingStatus();
});
```

- [ ] **Step 2: Unwrap `CachedValue` and show the offline banner in `_TodaySummaryCard`**

In `lib/features/dashboard/dashboard_screen.dart`, update the `_TodaySummaryCard` class (currently lines 138-259):

Change the field type:
```dart
  final AsyncValue<CachedValue<MacroGoal>> goal;
```

Change the body after the loading/error early-returns (currently `final goalValue = goal.requireValue;`) to:
```dart
    final goalCached = goal.requireValue;
    final goalValue = goalCached.value;
    final totalsValue = totals.requireValue;
    final remaining = goalValue.calorieTarget - totalsValue.calories.round();
```

Add the import at the top of the file:
```dart
import '../../core/local_db/cached_fetch.dart';
```

Add the offline banner right after the existing "remaining kcal" `Container` block inside the `Column`'s `children` (still inside `HeroCard`'s child `Column`, after the block that ends with the `remaining` text), so the full tail of the `Column`'s children reads:
```dart
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantics.muted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.sparkles, size: 16, color: semantics.mutedForeground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    remaining > 0
                        ? 'Te faltan $remaining kcal para tu meta de hoy.'
                        : 'Superaste tu meta de hoy por ${-remaining} kcal.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (goalCached.fromCache) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: semantics.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.cloudOff, size: 16, color: semantics.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexion: mostrando los ultimos datos guardados.',
                      style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/core/api lib/features/dashboard`
Expected: 0 issues. If `LucideIcons.cloudOff` does not resolve, replace it with `LucideIcons.wifiOff` (both are standard Lucide icons; only one may be exposed by the installed `lucide_icons_flutter` version) and re-run.

- [ ] **Step 4: Commit**

```bash
git add lib/core/api/providers.dart lib/features/dashboard/dashboard_screen.dart
git commit -m "feat: read the active goal through the local cache, show an offline banner"
```

---

## Task 7: `WeightLog` model and `WeightLogsRepository`

**Files:**
- Create: `lib/models/weight_log.dart`
- Generated (by build_runner): `lib/models/weight_log.freezed.dart`
- Create: `lib/core/supabase/weight_logs_repository.dart`

**Interfaces:**
- Consumes: `cachedFetch`, `CachedValue<T>` (Task 4), `LocalCache` (Task 3), `numFromPostgrest` (Task 2).
- Produces: `class WeightLog { String id; double weightKg; double? bodyFatPct; double? waistCm; double? neckCm; double? hipsCm; DateTime loggedAt; }`; `class WeightLogsRepository(LocalCache cache)` with `Future<CachedValue<List<WeightLog>>> fetchRecent({int limit = 30})` and `Future<void> logWeight({required double weightKg, double? bodyFatPct, double? waistCm, double? neckCm, double? hipsCm, DateTime? loggedAt})`. Consumed by Task 8.

- [ ] **Step 1: Write the `WeightLog` model**

Create `lib/models/weight_log.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_log.freezed.dart';

/// Mirrors `public.weight_logs`
/// (`nutriflow/supabase/migrations/20260613_0007_body_and_fasting.sql:39-54`).
/// Weight is always stored/displayed in kg in this v1 - no kg/lb toggle yet,
/// see the "Alcance de UI v1" section of
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
@freezed
abstract class WeightLog with _$WeightLog {
  const factory WeightLog({
    required String id,
    required double weightKg,
    double? bodyFatPct,
    double? waistCm,
    double? neckCm,
    double? hipsCm,
    required DateTime loggedAt,
  }) = _WeightLog;
}
```

- [ ] **Step 2: Generate the freezed code**

Run:
```
dart run build_runner build --delete-conflicting-outputs
```
Expected: completes with 0 errors and creates `lib/models/weight_log.freezed.dart`.

- [ ] **Step 3: Write the repository**

Create `lib/core/supabase/weight_logs_repository.dart`:
```dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/weight_log.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'postgrest_numeric.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase CRUD for `weight_logs` (CLAUDE.md section 6 - simple
/// CRUD bypasses the Fase 1 REST API, RLS/`app_user_id()` scopes every
/// query, no explicit `user_id` filter needed on reads). Reads go through
/// the local cache, same as `MealLogsRepository` - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
class WeightLogsRepository {
  WeightLogsRepository(this._cache);

  final LocalCache _cache;
  final _uuid = const Uuid();

  static const _cacheKey = 'weight_logs_recent';

  Future<CachedValue<List<WeightLog>>> fetchRecent({int limit = 30}) {
    return cachedFetch<List<WeightLog>>(
      cache: _cache,
      key: _cacheKey,
      fetchRaw: () => supabase
          .from('weight_logs')
          .select()
          .isFilter('deleted_at', null)
          .order('logged_at', ascending: false)
          .limit(limit),
      decode: (raw) => (raw as List).cast<Map<String, dynamic>>().map(_toWeightLog).toList(),
      onNetworkError: (error, stackTrace) =>
          debugPrint('fetchRecent (weight_logs) failed, falling back to cache: $error\n$stackTrace'),
    );
  }

  /// Inserts a new entry. `weight_logs.id`/`user_id` have no server default
  /// (unlike tables written through the Fase 1 REST API), so both are
  /// resolved here: `id` client-side (uuid v4), `user_id` via the
  /// `app_user_id()` RPC - the same function the RLS policies use
  /// internally, called instead of duplicating clerk_id -> internal uuid
  /// resolution in Dart.
  Future<void> logWeight({
    required double weightKg,
    double? bodyFatPct,
    double? waistCm,
    double? neckCm,
    double? hipsCm,
    DateTime? loggedAt,
  }) async {
    final userId = await supabase.rpc('app_user_id') as String;
    await supabase.from('weight_logs').insert({
      'id': _uuid.v4(),
      'user_id': userId,
      'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (waistCm != null) 'waist_cm': waistCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
    });
  }

  WeightLog _toWeightLog(Map<String, dynamic> row) {
    return WeightLog(
      id: row['id'] as String,
      weightKg: numFromPostgrest(row['weight_kg']).toDouble(),
      bodyFatPct: row['body_fat_pct'] == null ? null : numFromPostgrest(row['body_fat_pct']).toDouble(),
      waistCm: row['waist_cm'] == null ? null : numFromPostgrest(row['waist_cm']).toDouble(),
      neckCm: row['neck_cm'] == null ? null : numFromPostgrest(row['neck_cm']).toDouble(),
      hipsCm: row['hips_cm'] == null ? null : numFromPostgrest(row['hips_cm']).toDouble(),
      loggedAt: DateTime.parse(row['logged_at'] as String),
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/models/weight_log.dart lib/core/supabase/weight_logs_repository.dart`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/models/weight_log.dart lib/models/weight_log.freezed.dart lib/core/supabase/weight_logs_repository.dart
git commit -m "feat: add WeightLog model and WeightLogsRepository"
```

---

## Task 8: Weight logs providers and `WeightLogScreen`

**Files:**
- Modify: `lib/core/supabase/providers.dart`
- Create: `lib/features/body_metrics/weight_log_screen.dart`

**Interfaces:**
- Consumes: `WeightLogsRepository`, `WeightLog` (Task 7), `localCacheProvider` (Task 3), `CachedValue<T>` (Task 4).
- Produces: `final weightLogsRepositoryProvider = Provider<WeightLogsRepository>`, `final recentWeightLogsProvider = FutureProvider.autoDispose<CachedValue<List<WeightLog>>>`, `class WeightLogScreen extends ConsumerStatefulWidget`. Consumed by Task 9 (router + dashboard nav).

- [ ] **Step 1: Add the weight logs providers**

Append to `lib/core/supabase/providers.dart` (after `todayMacroTotalsProvider`), and add the two new imports at the top:
```dart
import '../../models/weight_log.dart';
```
```dart
import 'weight_logs_repository.dart';
```
```dart
final weightLogsRepositoryProvider = Provider<WeightLogsRepository>((ref) {
  return WeightLogsRepository(ref.watch(localCacheProvider));
});

final recentWeightLogsProvider = FutureProvider.autoDispose<CachedValue<List<WeightLog>>>((ref) {
  return ref.watch(weightLogsRepositoryProvider).fetchRecent();
});
```

- [ ] **Step 2: Write the screen**

Create `lib/features/body_metrics/weight_log_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/weight_log.dart';
import '../../shared/widgets/hero_card.dart';

/// Body weight tracking (Fase 3). Direct-Supabase CRUD via
/// [WeightLogsRepository] - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
/// v1 is kg-only (no kg/lb toggle) and has no edit/delete, by design.
class WeightLogScreen extends ConsumerStatefulWidget {
  const WeightLogScreen({super.key});

  @override
  ConsumerState<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends ConsumerState<WeightLogScreen> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _neckController = TextEditingController();
  final _hipsController = TextEditingController();
  bool _advancedOpen = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  double? _parsePositive(String text, {double max = double.infinity}) {
    if (text.trim().isEmpty) return null;
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || value >= max) return null;
    return value;
  }

  Future<void> _submit() async {
    final weightKg = _parsePositive(_weightController.text, max: 500);
    if (weightKg == null) {
      setState(() => _error = 'Ingresa un peso valido en kg (entre 0 y 500).');
      return;
    }
    final bodyFatPct = _parsePositive(_bodyFatController.text, max: 100);
    final waistCm = _parsePositive(_waistController.text);
    final neckCm = _parsePositive(_neckController.text);
    final hipsCm = _parsePositive(_hipsController.text);

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(weightLogsRepositoryProvider).logWeight(
            weightKg: weightKg,
            bodyFatPct: bodyFatPct,
            waistCm: waistCm,
            neckCm: neckCm,
            hipsCm: hipsCm,
          );
      _weightController.clear();
      _bodyFatController.clear();
      _waistController.clear();
      _neckController.clear();
      _hipsController.clear();
      ref.invalidate(recentWeightLogsProvider);
    } catch (e) {
      setState(() => _error = 'No pudimos guardar el registro ($e).');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final recent = ref.watch(recentWeightLogsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Peso corporal'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            recent.when(
              data: (cached) => _LatestWeightCard(entries: cached.value, fromCache: cached.fromCache),
              loading: () => const HeroCard(
                child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              ),
              error: (error, _) => HeroCard(
                child: Text(
                  'No se pudo cargar tu historial de peso.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Registrar peso', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _advancedOpen = !_advancedOpen),
              icon: Icon(_advancedOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown),
              label: const Text('Composicion corporal (opcional)'),
            ),
            if (_advancedOpen) ...[
              TextField(
                controller: _bodyFatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Grasa corporal (%)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _waistController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cintura (cm)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _neckController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cuello (cm)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hipsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cadera (cm)'),
              ),
            ],
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
            const SizedBox(height: 24),
            Text('Historial reciente', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            recent.when(
              data: (cached) => cached.value.isEmpty
                  ? Text(
                      'Todavia no registras tu peso.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                    )
                  : Column(
                      children: [
                        for (final (index, entry) in cached.value.indexed) ...[
                          if (index > 0) const SizedBox(height: 10),
                          _WeightHistoryRow(entry: entry),
                        ],
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestWeightCard extends StatelessWidget {
  const _LatestWeightCard({required this.entries, required this.fromCache});

  final List<WeightLog> entries;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    if (entries.isEmpty) {
      return HeroCard(
        child: Text(
          'Registra tu primer peso para empezar a ver tu progreso.',
          style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
        ),
      );
    }

    final latest = entries.first;
    final previous = entries.length > 1 ? entries[1] : null;
    final delta = previous == null ? null : latest.weightKg - previous.weightKg;

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ultimo registro', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${latest.weightKg.toStringAsFixed(1)} kg', style: theme.textTheme.displaySmall),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta == 0
                  ? 'Sin cambio desde el registro anterior.'
                  : '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg desde el registro anterior.',
              style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
            ),
          ],
          if (fromCache) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: semantics.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.cloudOff, size: 16, color: semantics.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexion: mostrando los ultimos datos guardados.',
                      style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightHistoryRow extends StatelessWidget {
  const _WeightHistoryRow({required this.entry});

  final WeightLog entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final date = entry.loggedAt;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(formatted, style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground)),
          Text('${entry.weightKg.toStringAsFixed(1)} kg', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/core/supabase/providers.dart lib/features/body_metrics`
Expected: 0 issues. If `LucideIcons.cloudOff`, `LucideIcons.arrowLeft`, `LucideIcons.chevronUp`, or `LucideIcons.chevronDown` fail to resolve, check the installed `lucide_icons_flutter` version's exported icon names and swap in the closest equivalent (do not fall back to `Icons.*`, see Global Constraints).

- [ ] **Step 4: Commit**

```bash
git add lib/core/supabase/providers.dart lib/features/body_metrics
git commit -m "feat: add weight logs providers and the weight log screen"
```

---

## Task 9: Router route and dashboard entry point

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart:116-130` (`FloatingNavBar.onTap`)

**Interfaces:**
- Consumes: `WeightLogScreen` (Task 8).
- Produces: route `/weight` reachable from the dashboard.

- [ ] **Step 1: Register the route**

In `lib/app/router.dart`, add the import:
```dart
import '../features/body_metrics/weight_log_screen.dart';
```
Add a route to the `routes` list (after `/log/barcode`):
```dart
    GoRoute(path: '/weight', builder: (context, state) => const WeightLogScreen()),
```

- [ ] **Step 2: Wire the dashboard nav bar's third tab (`heartPulse`) to push it**

In `lib/features/dashboard/dashboard_screen.dart`, replace the `FloatingNavBar`'s `onTap`:
```dart
              onTap: (i) => setState(() => _navIndex = i),
```
with:
```dart
              onTap: (i) {
                setState(() => _navIndex = i);
                if (i == 2) {
                  context.push('/weight');
                }
              },
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/router.dart lib/features/dashboard/dashboard_screen.dart`
Expected: 0 issues.

- [ ] **Step 4: Commit**

```bash
git add lib/app/router.dart lib/features/dashboard/dashboard_screen.dart
git commit -m "feat: wire the dashboard's body-metrics tab to the weight log screen"
```

---

## Task 10: Full verification pass

**Files:** none (verification only).

- [ ] **Step 1: Static analysis across the whole project**

Run: `flutter analyze`
Expected: 0 errors. Any pre-existing warnings/infos noted in CLAUDE.md section 0 (3 infos as of 2026-07-17) are acceptable; no new errors.

- [ ] **Step 2: Full test suite**

Run: `flutter test`
Expected: all tests pass (`test/postgrest_numeric_test.dart`, `test/cached_fetch_test.dart`, 7 tests total).

- [ ] **Step 3: Confirm codegen is fully up to date**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes with 0 errors and no unexpected file changes (everything was already generated in Tasks 3 and 7).

- [ ] **Step 4: Debug APK build**

Run: `flutter build apk --debug`
Expected: builds successfully with the new native `sqlite3_flutter_libs` plugin linked in.

- [ ] **Step 5: Manual device QA (Samsung Galaxy A55 physical device, per CLAUDE.md - the only environment where auth is confirmed to work)**

Run: `flutter run -d <serial>`

Checklist:
- From the dashboard, tap the body-metrics (heart pulse) nav icon, confirm it opens "Peso corporal".
- Log a weight (with and without the optional composition fields expanded), confirm it appears at the top of "Historial reciente" and updates the "Ultimo registro" card, including the delta text on the second entry.
- With the dashboard and the weight screen each loaded at least once (so both have cached data), turn off Wi-Fi/mobile data on the device (or stop the `nutriflow` dev server), then relaunch the app: confirm the dashboard's goal/meals and the weight history still render with their last known values, and the "Sin conexion: mostrando los ultimos datos guardados." banner appears on both the dashboard summary card and the weight screen's latest-weight card.
- Restore connectivity, pull/refresh (or relaunch), confirm the banner disappears and fresh data loads.

- [ ] **Step 6: Update CLAUDE.md's bitacora**

Add a new dated entry to `CLAUDE.md` section 10 (top of the list, most recent first) summarizing: weight logs feature shipped (direct-Supabase CRUD, kg-only v1), local read cache shipped (Drift-backed `CacheEntries` key-value table, `cachedFetch` helper, wired into `todayMealEntriesProvider`/`goalProvider`/`recentWeightLogsProvider`), and the result of the manual device QA in Step 5 (what worked, anything that did not). Update section 0's "Siguiente accion concreta" to drop the now-done item and note whatever should come next (fasting timer or favorites/recipes, per the roadmap in section 8).

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update bitacora for weight logs and local read cache"
```
