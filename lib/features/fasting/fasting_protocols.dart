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
