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
