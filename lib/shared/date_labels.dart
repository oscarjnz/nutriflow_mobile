/// Spanish date vocabulary and day arithmetic used across the dashboard and
/// the calendar.
///
/// Deliberately not `intl`'s `DateFormat`: locale-aware formatting needs
/// `initializeDateFormatting('es')` before first use, which is one more piece
/// of async startup that can silently produce English labels if it is ever
/// skipped. The UI is Spanish-only (CLAUDE.md section 5), so a fixed table is
/// both simpler and impossible to get wrong at runtime.
library;

/// Monday-first, matching how the week strip reads in the dashboard.
const _weekdayNames = <String>[
  'lunes',
  'martes',
  'miercoles',
  'jueves',
  'viernes',
  'sabado',
  'domingo',
];

/// Single-letter labels for the compact week strip. Tuesday and Wednesday
/// both start with "M", which is expected: the day number underneath is what
/// disambiguates them.
const _weekdayInitials = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];

const _monthNames = <String>[
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Every function here reads `.year`/`.month`/`.day`/`.weekday`, and on a UTC
/// [DateTime] those are the UTC wall-clock fields, not the user's. Since
/// `DateTime.parse` of a PostgREST timestamp returns a UTC value, passing a
/// raw row value straight into any of these would silently date it by UTC's
/// calendar - the same defect fixed in `pgTimestamp`/`.toLocal()`, which no
/// compiler or test would catch. Normalizing on the way in makes that
/// impossible rather than merely discouraged.
DateTime _local(DateTime date) => date.isUtc ? date.toLocal() : date;

/// `DateTime.weekday` is 1..7 starting at Monday, so it maps straight onto
/// the Monday-first tables above once shifted to a 0-based index.
String weekdayName(DateTime date) => _weekdayNames[_local(date).weekday - 1];

String weekdayInitial(DateTime date) => _weekdayInitials[_local(date).weekday - 1];

String monthName(DateTime date) => _monthNames[_local(date).month - 1];

/// "jueves, 31 de julio de 2026" - the full date, for headers.
String fullDateLabel(DateTime date) {
  final d = _local(date);
  return '${weekdayName(d)}, ${d.day} de ${monthName(d)} de ${d.year}';
}

/// "31 de julio" - the date without weekday or year, for tighter spots.
String shortDateLabel(DateTime date) {
  final d = _local(date);
  return '${d.day} de ${monthName(d)}';
}

/// "julio de 2026" - the calendar's month header.
String monthYearLabel(DateTime date) {
  final d = _local(date);
  return '${monthName(d)} de ${d.year}';
}

/// Midnight local time, which is what every day-range query keys off.
DateTime startOfDay(DateTime date) {
  final d = _local(date);
  return DateTime(d.year, d.month, d.day);
}

/// The Monday of [date]'s week, at midnight. Built by calendar arithmetic
/// rather than by subtracting a fixed-length `Duration`, which would drift by
/// an hour across a DST transition (no DST in the DR, but the app should not
/// be wrong elsewhere for free).
DateTime startOfWeek(DateTime date) {
  final d = _local(date);
  return DateTime(d.year, d.month, d.day - (d.weekday - 1));
}

/// Whether both instants fall on the same local calendar day.
bool isSameDay(DateTime a, DateTime b) {
  final x = _local(a);
  final y = _local(b);
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

/// A stable `yyyy-mm-dd` key, used for per-day cache entries. Built by hand
/// rather than from `toIso8601String()` so it always reflects the LOCAL day,
/// never a UTC-shifted one.
String dayKey(DateTime date) {
  final d = _local(date);
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
