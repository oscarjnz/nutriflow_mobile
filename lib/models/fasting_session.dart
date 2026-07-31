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
