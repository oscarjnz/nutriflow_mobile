# Fasting Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fasting timer feature (start/end/cancel a fast, live elapsed-time display, history) backed directly by Supabase's existing `fasting_sessions` table.

**Architecture:** Direct-Supabase CRUD through a new `FastingSessionsRepository`, following the exact pattern already established by `WeightLogsRepository` (`lib/core/supabase/weight_logs_repository.dart`): client-generated `uuid` v4 ids, `user_id` resolved via the `app_user_id()` RPC, reads wrapped in `cachedFetch` for offline fallback, writes uncached. A new `FastingScreen` (route `/fasting`) is reached from an AppBar icon on `WeightLogScreen`, mirroring the existing barcode-scan entry point on `LoggingScreen`.

**Tech Stack:** Flutter/Dart, Riverpod (`FutureProvider.autoDispose`), `freezed` for the model, `supabase_flutter` for direct CRUD, existing Drift-backed `cachedFetch`/`LocalCache` infra (no changes to that infra).

## Global Constraints

- No business/calculation logic beyond simple client-side display math (elapsed duration, progress ratio) - CLAUDE.md section 1/9. The "one active fast per user" rule is enforced by the DB's `fasting_active_per_user` unique index; the client only translates the resulting error, never re-validates the rule itself before inserting.
- Null-safety strict, no `dynamic` outside JSON deserialization boundaries - CLAUDE.md section 9.
- Never call Supabase directly from a widget - always through `core/supabase/*_repository.dart` - CLAUDE.md section 9.
- Never silence an error / never empty `catch` - CLAUDE.md section 9. All write failures surface a curated message to the user; all errors are also `debugPrint`-logged with context.
- UI text in Spanish, code/identifiers/comments in English - CLAUDE.md section 5.
- Icons via `lucide_icons_flutter` (`LucideIcons.*`) only, never `Icons.*` - CLAUDE.md section 5.
- No em dash (`—`) or en dash (`–`) anywhere, including code comments and commit messages - global user instruction. Use a regular hyphen `-`.
- Rachas (`user_streaks`) are explicitly out of scope for this plan - see `docs/superpowers/specs/2026-07-31-fasting-timer-design.md`.

---

### Task 1: `FastingSession` model

**Files:**
- Create: `lib/models/fasting_session.dart`
- Generated (via build_runner, not hand-written): `lib/models/fasting_session.freezed.dart`

**Interfaces:**
- Produces: `FastingSession` class with fields `id (String)`, `startAt (DateTime)`, `endAt (DateTime?)`, `targetHours (int)`, `protocol (String)`, `notes (String?)`, and its `_FastingSession` factory constructor - used by Task 3 (repository mapping) and Task 5 (UI).

- [ ] **Step 1: Write the model**

```dart
// lib/models/fasting_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fasting_session.freezed.dart';

/// Mirrors `public.fasting_sessions`
/// (`nutriflow/supabase/migrations/20260613_0007_body_and_fasting.sql:17-36`).
/// `endAt == null` means the fast is still in progress - the table's partial
/// unique index (`fasting_active_per_user`) guarantees at most one such row
/// per user, see docs/superpowers/specs/2026-07-31-fasting-timer-design.md.
@freezed
abstract class FastingSession with _$FastingSession {
  const factory FastingSession({
    required String id,
    required DateTime startAt,
    DateTime? endAt,
    required int targetHours,
    required String protocol,
    String? notes,
  }) = _FastingSession;
}
```

- [ ] **Step 2: Generate the freezed code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/models/fasting_session.freezed.dart` is created, build finishes with no errors.

- [ ] **Step 3: Verify analysis is clean**

Run: `flutter analyze`
Expected: no new errors (the project has a small set of pre-existing info-level lints - do not fix unrelated ones).

- [ ] **Step 4: Commit**

```bash
git add lib/models/fasting_session.dart lib/models/fasting_session.freezed.dart
git commit -m "feat: add FastingSession model"
```

---

### Task 2: Fasting protocols, custom-hours validation, duration formatting

**Files:**
- Create: `lib/features/fasting/fasting_protocols.dart`
- Test: `test/fasting_protocols_test.dart`

**Interfaces:**
- Produces: `class FastingProtocol { final String id; final String label; final int? targetHours; }`, `const List<FastingProtocol> fastingProtocols`, `int? parseCustomTargetHours(String text)`, `String formatFastingDuration(Duration duration)` - used by Task 5 (`FastingScreen` and its child widgets).

- [ ] **Step 1: Write the failing tests**

```dart
// test/fasting_protocols_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/features/fasting/fasting_protocols.dart';

void main() {
  group('parseCustomTargetHours', () {
    test('accepts a value within 1-72', () {
      expect(parseCustomTargetHours('24'), 24);
    });

    test('rejects zero', () {
      expect(parseCustomTargetHours('0'), isNull);
    });

    test('rejects values above 72', () {
      expect(parseCustomTargetHours('73'), isNull);
    });

    test('rejects non-numeric input', () {
      expect(parseCustomTargetHours('abc'), isNull);
    });
  });

  group('formatFastingDuration', () {
    test('formats hours and minutes', () {
      expect(formatFastingDuration(const Duration(hours: 14, minutes: 32)), '14h 32m');
    });

    test('formats durations under an hour', () {
      expect(formatFastingDuration(const Duration(minutes: 45)), '0h 45m');
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/fasting_protocols_test.dart`
Expected: FAIL - `package:nutriflow_mobile/features/fasting/fasting_protocols.dart` does not exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/features/fasting/fasting_protocols.dart

/// Presets mirroring the `protocol` check constraint on `fasting_sessions`
/// (`nutriflow/supabase/migrations/20260613_0007_body_and_fasting.sql:23`).
/// `targetHours == null` for the `custom` preset means the user enters
/// their own value, validated by [parseCustomTargetHours] as a fast
/// client-side rejection - the table's `target_hours > 0 and <= 72` check
/// stays the actual source of truth.
class FastingProtocol {
  const FastingProtocol({required this.id, required this.label, required this.targetHours});

  final String id;
  final String label;
  final int? targetHours;
}

const fastingProtocols = [
  FastingProtocol(id: '12:12', label: '12:12', targetHours: 12),
  FastingProtocol(id: '14:10', label: '14:10', targetHours: 14),
  FastingProtocol(id: '16:8', label: '16:8', targetHours: 16),
  FastingProtocol(id: '18:6', label: '18:6', targetHours: 18),
  FastingProtocol(id: '20:4', label: '20:4', targetHours: 20),
  FastingProtocol(id: 'custom', label: 'Personalizado', targetHours: null),
];

int? parseCustomTargetHours(String text) {
  final value = int.tryParse(text.trim());
  if (value == null || value < 1 || value > 72) return null;
  return value;
}

String formatFastingDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/fasting_protocols_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/fasting/fasting_protocols.dart test/fasting_protocols_test.dart
git commit -m "feat: add fasting protocol presets and duration helpers"
```

---

### Task 3: `FastingSessionsRepository`

**Files:**
- Create: `lib/core/supabase/fasting_sessions_repository.dart`
- Test: `test/fasting_sessions_repository_test.dart`

**Interfaces:**
- Consumes: `FastingSession` (Task 1), `LocalCache`/`CachedValue`/`cachedFetch` (`lib/core/local_db/local_cache.dart`, `cached_value.dart`, `cached_fetch.dart` - already exist), `supabase` getter (`lib/core/supabase/supabase_bootstrap.dart` - already exists).
- Produces: `class FastingSessionsRepository { FastingSessionsRepository(LocalCache cache); Future<CachedValue<FastingSession?>> fetchActive(); Future<CachedValue<List<FastingSession>>> fetchHistory({int limit = 30}); Future<void> startFast({required String protocol, required int targetHours, String? notes}); Future<void> endFast(String id); Future<void> cancelFast(String id); }`, top-level `String? curatedFastingError(Object error)`, and top-level `FastingSession fastingSessionFromRow(Map<String, dynamic> row)` - used by Task 4 (providers) and Task 5 (UI).

`curatedFastingError` and `fastingSessionFromRow` are pure functions and get unit tests here. The row-mapping logic is a top-level function rather than a private method specifically so it's reachable from a test file (Dart's `_`-prefixed members are library-private, invisible to `test/`). The Supabase-calling methods themselves (`fetchActive`/`fetchHistory`/`startFast`/`endFast`/`cancelFast`) are not unit-tested beyond that mapping, matching the existing precedent: `WeightLogsRepository` (same shape) has no live-call tests today because there is no fake/mock Supabase client in this codebase yet.

- [ ] **Step 1: Write the failing tests**

```dart
// test/fasting_sessions_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/fasting_sessions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('curatedFastingError', () {
    test('curates the unique-violation on fasting_active_per_user', () {
      const error = PostgrestException(message: 'duplicate key value', code: '23505');
      expect(curatedFastingError(error), 'Ya tienes un ayuno en curso.');
    });

    test('returns null for other Postgrest errors', () {
      const error = PostgrestException(message: 'server error', code: '500');
      expect(curatedFastingError(error), isNull);
    });

    test('returns null for non-Postgrest errors', () {
      expect(curatedFastingError(Exception('boom')), isNull);
    });
  });

  group('fastingSessionFromRow', () {
    test('maps a finished session row', () {
      final session = fastingSessionFromRow({
        'id': 'session-1',
        'start_at': '2026-07-30T20:00:00.000Z',
        'end_at': '2026-07-31T12:00:00.000Z',
        'target_hours': 16,
        'protocol': '16:8',
        'notes': 'sin cafe',
      });

      expect(session.id, 'session-1');
      expect(session.startAt, DateTime.parse('2026-07-30T20:00:00.000Z'));
      expect(session.endAt, DateTime.parse('2026-07-31T12:00:00.000Z'));
      expect(session.targetHours, 16);
      expect(session.protocol, '16:8');
      expect(session.notes, 'sin cafe');
    });

    test('maps an in-progress session row (end_at and notes null)', () {
      final session = fastingSessionFromRow({
        'id': 'session-2',
        'start_at': '2026-07-31T08:00:00.000Z',
        'end_at': null,
        'target_hours': 12,
        'protocol': '12:12',
        'notes': null,
      });

      expect(session.endAt, isNull);
      expect(session.notes, isNull);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/fasting_sessions_repository_test.dart`
Expected: FAIL - `package:nutriflow_mobile/core/supabase/fasting_sessions_repository.dart` does not exist.

- [ ] **Step 3: Write the repository**

```dart
// lib/core/supabase/fasting_sessions_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/fasting_session.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase CRUD for `fasting_sessions` (CLAUDE.md section 6), same
/// pattern as `WeightLogsRepository`. See
/// docs/superpowers/specs/2026-07-31-fasting-timer-design.md.
class FastingSessionsRepository {
  FastingSessionsRepository(this._cache);

  final LocalCache _cache;
  final _uuid = const Uuid();

  static const _activeCacheKey = 'fasting_active';
  static const _historyCacheKey = 'fasting_history';

  /// Fetches the in-progress session (`end_at is null`), if any. The raw
  /// fetch returns `{}` instead of `null` when there is none, so the cache
  /// stores a real JSON value either way - `cachedFetch`'s fallback path
  /// treats a cached `null` the same as "nothing was ever cached" (see
  /// `local_db/local_cache.dart`), which would otherwise make a network
  /// failure wrongly rethrow instead of correctly falling back to "no
  /// active fast, from cache".
  Future<CachedValue<FastingSession?>> fetchActive() {
    return cachedFetch<FastingSession?>(
      cache: _cache,
      key: _activeCacheKey,
      fetchRaw: () async {
        final row = await supabase
            .from('fasting_sessions')
            .select()
            .isFilter('end_at', null)
            .isFilter('deleted_at', null)
            .maybeSingle();
        return row ?? <String, dynamic>{};
      },
      decode: (raw) {
        final row = raw as Map<String, dynamic>;
        return row.isEmpty ? null : fastingSessionFromRow(row);
      },
      onNetworkError: (error, stackTrace) => debugPrint(
        'fetchActive (fasting_sessions) failed, falling back to cache: $error\n$stackTrace',
      ),
      onCacheWriteError: (error, stackTrace) => debugPrint(
        'fetchActive (fasting_sessions) could not update the cache: $error\n$stackTrace',
      ),
    );
  }

  /// Only finished sessions (`end_at is not null`) - the active one, if any,
  /// is shown separately via [fetchActive].
  Future<CachedValue<List<FastingSession>>> fetchHistory({int limit = 30}) {
    return cachedFetch<List<FastingSession>>(
      cache: _cache,
      key: _historyCacheKey,
      fetchRaw: () => supabase
          .from('fasting_sessions')
          .select()
          .isFilter('deleted_at', null)
          .not('end_at', 'is', null)
          .order('start_at', ascending: false)
          .limit(limit),
      decode: (raw) => (raw as List).cast<Map<String, dynamic>>().map(fastingSessionFromRow).toList(),
      onNetworkError: (error, stackTrace) => debugPrint(
        'fetchHistory (fasting_sessions) failed, falling back to cache: $error\n$stackTrace',
      ),
      onCacheWriteError: (error, stackTrace) => debugPrint(
        'fetchHistory (fasting_sessions) could not update the cache: $error\n$stackTrace',
      ),
    );
  }

  /// Starts a new fast. `fasting_active_per_user` (a partial unique index on
  /// `user_id where end_at is null and deleted_at is null`) is the single
  /// source of truth for "one active fast at a time" - this only translates
  /// the resulting Postgres error into a curated message via
  /// [curatedFastingError], it does not duplicate the rule client-side.
  Future<void> startFast({
    required String protocol,
    required int targetHours,
    String? notes,
  }) async {
    final userId = await supabase.rpc('app_user_id') as String;
    try {
      await supabase.from('fasting_sessions').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'start_at': DateTime.now().toIso8601String(),
        'target_hours': targetHours,
        'protocol': protocol,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
    } catch (error) {
      final curated = curatedFastingError(error);
      if (curated != null) throw StateError(curated);
      rethrow;
    }
  }

  Future<void> endFast(String id) {
    return supabase
        .from('fasting_sessions')
        .update({'end_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> cancelFast(String id) {
    return supabase
        .from('fasting_sessions')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}

/// Translates a Postgres unique-violation on `fasting_active_per_user`
/// (SQLSTATE 23505) into a curated message. Returns null for any other
/// error, so callers know to rethrow it unchanged.
String? curatedFastingError(Object error) {
  if (error is PostgrestException && error.code == '23505') {
    return 'Ya tienes un ayuno en curso.';
  }
  return null;
}

/// Top-level (not a private repository method) so it's directly unit
/// testable from `test/` - Dart's `_`-prefixed members are library-private.
FastingSession fastingSessionFromRow(Map<String, dynamic> row) {
  return FastingSession(
    id: row['id'] as String,
    startAt: DateTime.parse(row['start_at'] as String),
    endAt: row['end_at'] == null ? null : DateTime.parse(row['end_at'] as String),
    targetHours: row['target_hours'] as int,
    protocol: row['protocol'] as String,
    notes: row['notes'] as String?,
  );
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/fasting_sessions_repository_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Verify analysis is clean**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 6: Commit**

```bash
git add lib/core/supabase/fasting_sessions_repository.dart test/fasting_sessions_repository_test.dart
git commit -m "feat: add FastingSessionsRepository"
```

---

### Task 4: Riverpod providers

**Files:**
- Modify: `lib/core/supabase/providers.dart`

**Interfaces:**
- Consumes: `FastingSessionsRepository` (Task 3), `localCacheProvider` (`lib/core/local_db/providers.dart` - already exists).
- Produces: `fastingSessionsRepositoryProvider (Provider<FastingSessionsRepository>)`, `activeFastingSessionProvider (FutureProvider.autoDispose<CachedValue<FastingSession?>>)`, `recentFastingSessionsProvider (FutureProvider.autoDispose<CachedValue<List<FastingSession>>>)` - used by Task 5 (UI).

There is no separate test for this task - `FutureProvider` wiring has no existing test precedent in this codebase (`recentWeightLogsProvider` isn't tested either); correctness is verified by the UI actually rendering data in Task 5's manual check and Task 6's final build.

- [ ] **Step 1: Add the imports and providers**

Add these imports to `lib/core/supabase/providers.dart` (alongside the existing `weight_log.dart`/`weight_logs_repository.dart` imports):

```dart
import '../../models/fasting_session.dart';
import 'fasting_sessions_repository.dart';
```

Append at the end of the file:

```dart
final fastingSessionsRepositoryProvider = Provider<FastingSessionsRepository>((ref) {
  return FastingSessionsRepository(ref.watch(localCacheProvider));
});

final activeFastingSessionProvider = FutureProvider.autoDispose<CachedValue<FastingSession?>>((ref) {
  return ref.watch(fastingSessionsRepositoryProvider).fetchActive();
});

final recentFastingSessionsProvider = FutureProvider.autoDispose<CachedValue<List<FastingSession>>>((ref) {
  return ref.watch(fastingSessionsRepositoryProvider).fetchHistory();
});
```

- [ ] **Step 2: Verify analysis is clean**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/supabase/providers.dart
git commit -m "feat: add fasting session providers"
```

---

### Task 5: `FastingScreen`

**Files:**
- Create: `lib/features/fasting/fasting_screen.dart`

**Interfaces:**
- Consumes: `FastingSession` (Task 1), `fastingProtocols`/`parseCustomTargetHours`/`formatFastingDuration` (Task 2), `fastingSessionsRepositoryProvider`/`activeFastingSessionProvider`/`recentFastingSessionsProvider` (Task 4), `HeroCard` (`lib/shared/widgets/hero_card.dart` - already exists), `NutriFlowSemanticColors` (`lib/core/theme/colors.dart` - already exists).
- Produces: `class FastingScreen extends ConsumerStatefulWidget` - used by Task 6 (router wiring).

No new test file - matches the existing precedent that screens (`WeightLogScreen`, `LoggingScreen`) have no widget tests in this codebase yet. Verified manually once wired up in Task 6.

- [ ] **Step 1: Write the screen**

```dart
// lib/features/fasting/fasting_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/fasting_session.dart';
import '../../shared/widgets/hero_card.dart';
import 'fasting_protocols.dart';

/// Fasting timer (Fase 3). Direct-Supabase CRUD via
/// [FastingSessionsRepository] - see
/// docs/superpowers/specs/2026-07-31-fasting-timer-design.md.
/// Streaks are explicitly out of scope for v1.
class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  String _protocolId = fastingProtocols.first.id;
  final _customHoursController = TextEditingController();
  final _notesController = TextEditingController();
  bool _starting = false;
  bool _ending = false;
  bool _canceling = false;
  String? _error;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _customHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Runs a 1s ticker only while an active fast is on screen, so the
  /// elapsed-time text advances live without re-querying the provider each
  /// second. Cancelled as soon as there's no active fast, and always in
  /// [dispose].
  void _ensureTicker(bool shouldRun) {
    if (shouldRun && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!shouldRun && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  Future<void> _startFast() async {
    final protocol = fastingProtocols.firstWhere((p) => p.id == _protocolId);
    int? targetHours = protocol.targetHours;
    if (targetHours == null) {
      targetHours = parseCustomTargetHours(_customHoursController.text);
      if (targetHours == null) {
        setState(() => _error = 'Ingresa horas validas para el ayuno personalizado (entre 1 y 72).');
        return;
      }
    }

    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await ref.read(fastingSessionsRepositoryProvider).startFast(
            protocol: _protocolId,
            targetHours: targetHours,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );
      _notesController.clear();
      _customHoursController.clear();
      ref.invalidate(activeFastingSessionProvider);
      ref.invalidate(recentFastingSessionsProvider);
    } catch (e) {
      debugPrint('startFast failed: $e');
      setState(() => _error = e is StateError ? e.message : 'No pudimos iniciar el ayuno. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _endFast(String id) async {
    setState(() => _ending = true);
    try {
      await ref.read(fastingSessionsRepositoryProvider).endFast(id);
      ref.invalidate(activeFastingSessionProvider);
      ref.invalidate(recentFastingSessionsProvider);
    } catch (e) {
      debugPrint('endFast failed: $e');
      setState(() => _error = 'No pudimos terminar el ayuno. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  Future<void> _cancelFast(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar ayuno'),
        content: const Text('Se eliminara este registro. Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancelar ayuno')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _canceling = true);
    try {
      await ref.read(fastingSessionsRepositoryProvider).cancelFast(id);
      ref.invalidate(activeFastingSessionProvider);
      ref.invalidate(recentFastingSessionsProvider);
    } catch (e) {
      debugPrint('cancelFast failed: $e');
      setState(() => _error = 'No pudimos cancelar el ayuno. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _canceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final active = ref.watch(activeFastingSessionProvider);
    final history = ref.watch(recentFastingSessionsProvider);

    _ensureTicker(active.asData?.value.value != null);

    final fromCache =
        (active.asData?.value.fromCache ?? false) || (history.asData?.value.fromCache ?? false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ayuno'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            active.when(
              data: (cached) => cached.value == null
                  ? _StartFastCard(
                      protocolId: _protocolId,
                      onProtocolChanged: (id) => setState(() => _protocolId = id),
                      customHoursController: _customHoursController,
                      notesController: _notesController,
                      starting: _starting,
                      error: _error,
                      onSubmit: _startFast,
                    )
                  : _ActiveFastCard(
                      session: cached.value!,
                      ending: _ending,
                      canceling: _canceling,
                      onEnd: () => _endFast(cached.value!.id),
                      onCancel: () => _cancelFast(cached.value!.id),
                    ),
              loading: () => const HeroCard(
                child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              ),
              error: (error, _) => HeroCard(
                child: Text(
                  'No se pudo cargar tu estado de ayuno.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              ),
            ),
            if (fromCache) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: semantics.muted, borderRadius: BorderRadius.circular(16)),
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
            const SizedBox(height: 24),
            Text('Historial reciente', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            history.when(
              data: (cached) => cached.value.isEmpty
                  ? Text(
                      'Todavia no completas ningun ayuno.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                    )
                  : Column(
                      children: [
                        for (final (index, session) in cached.value.indexed) ...[
                          if (index > 0) const SizedBox(height: 10),
                          _FastingHistoryRow(session: session),
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

class _StartFastCard extends StatelessWidget {
  const _StartFastCard({
    required this.protocolId,
    required this.onProtocolChanged,
    required this.customHoursController,
    required this.notesController,
    required this.starting,
    required this.error,
    required this.onSubmit,
  });

  final String protocolId;
  final ValueChanged<String> onProtocolChanged;
  final TextEditingController customHoursController;
  final TextEditingController notesController;
  final bool starting;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = protocolId == 'custom';

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Empezar ayuno', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final protocol in fastingProtocols)
                ChoiceChip(
                  label: Text(protocol.label),
                  selected: protocolId == protocol.id,
                  onSelected: (_) => onProtocolChanged(protocol.id),
                ),
            ],
          ),
          if (isCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: customHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas objetivo (1-72)'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: 16),
          if (error != null) ...[
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: starting ? null : onSubmit,
            child: starting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Empezar ayuno'),
          ),
        ],
      ),
    );
  }
}

class _ActiveFastCard extends StatelessWidget {
  const _ActiveFastCard({
    required this.session,
    required this.ending,
    required this.canceling,
    required this.onEnd,
    required this.onCancel,
  });

  final FastingSession session;
  final bool ending;
  final bool canceling;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final elapsed = DateTime.now().difference(session.startAt);
    final targetSeconds = Duration(hours: session.targetHours).inSeconds;
    final progress = (elapsed.inSeconds / targetSeconds).clamp(0.0, 1.0);

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ayuno en curso - ${session.protocol}', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(formatFastingDuration(elapsed), style: theme.textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            'de ${session.targetHours}h',
            style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: ending ? null : onEnd,
                  child: ending
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Terminar ayuno'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: canceling ? null : onCancel,
                  child: canceling
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FastingHistoryRow extends StatelessWidget {
  const _FastingHistoryRow({required this.session});

  final FastingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final date = session.startAt;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    // fetchHistory() only returns rows where end_at is not null.
    final duration = session.endAt!.difference(session.startAt);

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.protocol, style: theme.textTheme.titleMedium),
              Text(formatted, style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground)),
            ],
          ),
          Text(formatFastingDuration(duration), style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analysis is clean**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fasting/fasting_screen.dart
git commit -m "feat: add FastingScreen"
```

---

### Task 6: Wire up navigation

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/body_metrics/weight_log_screen.dart`

**Interfaces:**
- Consumes: `FastingScreen` (Task 5).

- [ ] **Step 1: Add the route**

In `lib/app/router.dart`, add the import alongside the existing feature imports:

```dart
import '../features/fasting/fasting_screen.dart';
```

Add the route to the `routes` list, after the `/weight` route:

```dart
    GoRoute(path: '/fasting', builder: (context, state) => const FastingScreen()),
```

- [ ] **Step 2: Add the entry icon to `WeightLogScreen`'s AppBar**

In `lib/features/body_metrics/weight_log_screen.dart`, change the `appBar:` block (currently only has `leading`) to also have `actions`, matching the exact pattern already used in `lib/features/logging/logging_screen.dart:110-119` for the barcode-scan entry point:

```dart
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Peso corporal'),
        actions: [
          IconButton(
            tooltip: 'Ayuno',
            icon: const Icon(LucideIcons.timer),
            onPressed: () => context.push('/fasting'),
          ),
        ],
      ),
```

- [ ] **Step 3: Verify analysis is clean**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 4: Commit**

```bash
git add lib/app/router.dart lib/features/body_metrics/weight_log_screen.dart
git commit -m "feat: wire up navigation to the fasting screen"
```

---

### Task 7: Final verification and bitacora update

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Run the full analyzer**

Run: `flutter analyze`
Expected: 0 errors (pre-existing info-level lints are fine, no new ones).

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: all tests pass, including the new `test/fasting_protocols_test.dart` (6 tests) and `test/fasting_sessions_repository_test.dart` (5 tests) on top of the existing 10.

- [ ] **Step 3: Confirm codegen is up to date**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 0 files written (everything was already generated and committed in Task 1).

- [ ] **Step 4: Build a debug APK**

Run: `flutter build apk --debug`
Expected: builds cleanly (only the pre-existing, unrelated KGP warning from `mobile_scanner`/`passkeys_android`/`ua_client_hints`, same as prior sessions).

- [ ] **Step 5: Update `CLAUDE.md`**

Add a new bitacora entry (most recent first, per the file's own convention) documenting: what was built (fasting timer, direct-Supabase CRUD, cached reads, live ticker), that rachas were explicitly deferred, the `fetchActive` cache-null-vs-unset distinction (real gotcha worth keeping for future `cachedFetch` usages with a nullable `T`), and that manual on-device QA (start/end/cancel a fast, second-fast-blocked message, offline banner) is still pending - same "no physical device in this session" caveat pattern as prior entries if applicable, or the actual on-device result if a device was available by the time this task runs. Update the Fase 3 table row in section 8 to mark fasting timer done, and update "Siguiente accion concreta" in section 0 accordingly.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update bitacora for the fasting timer feature"
```
