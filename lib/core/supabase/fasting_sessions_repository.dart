import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/fasting_session.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'pg_timestamp.dart';
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
        'start_at': pgTimestamp(DateTime.now()),
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
        .update({'end_at': pgTimestamp(DateTime.now())})
        .eq('id', id);
  }

  Future<void> cancelFast(String id) {
    return supabase
        .from('fasting_sessions')
        .update({'deleted_at': pgTimestamp(DateTime.now())})
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
    // `.toLocal()` is not cosmetic: PostgREST sends an offset-bearing string,
    // so `DateTime.parse` yields a UTC value whose `.day`/`.hour` are UTC
    // components. Rendering those directly would date a 21:00 fast in Santo
    // Domingo (UTC-4) as the following day.
    startAt: DateTime.parse(row['start_at'] as String).toLocal(),
    endAt: row['end_at'] == null ? null : DateTime.parse(row['end_at'] as String).toLocal(),
    targetHours: row['target_hours'] as int,
    protocol: row['protocol'] as String,
    notes: row['notes'] as String?,
  );
}
