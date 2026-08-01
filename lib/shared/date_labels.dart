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

/// `DateTime.weekday` is 1..7 starting at Monday, so it maps straight onto
/// the Monday-first tables above once shifted to a 0-based index.
String weekdayName(DateTime date) => _weekdayNames[date.weekday - 1];

String weekdayInitial(DateTime date) => _weekdayInitials[date.weekday - 1];

String monthName(DateTime date) => _monthNames[date.month - 1];

/// "jueves, 31 de julio de 2026" - the full date, for headers.
String fullDateLabel(DateTime date) =>
    '${weekdayName(date)}, ${date.day} de ${monthName(date)} de ${date.year}';

/// "31 de julio" - the date without weekday or year, for tighter spots.
String shortDateLabel(DateTime date) => '${date.day} de ${monthName(date)}';

/// "julio de 2026" - the calendar's month header.
String monthYearLabel(DateTime date) => '${monthName(date)} de ${date.year}';

/// Midnight local time, which is what every day-range query keys off.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// The Monday of [date]'s week, at midnight.
DateTime startOfWeek(DateTime date) =>
    startOfDay(date).subtract(Duration(days: date.weekday - 1));

/// Whether both instants fall on the same local calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// A stable `yyyy-mm-dd` key, used for per-day cache entries. Built by hand
/// rather than from `toIso8601String()` so it always reflects the LOCAL day,
/// never a UTC-shifted one.
String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
