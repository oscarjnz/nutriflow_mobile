import 'package:flutter/material.dart';

/// Warm-tinted ambient shadows, ported from `--shadow-soft` / `--shadow-float`
/// in globals.css. Never use `Colors.black` - shadow color is always mixed
/// from `foreground` (light) so surfaces read as floating in warm light
/// rather than cut from paper (CLAUDE.md section 5). Flutter has no native
/// inset shadow, so the web's `inset 0 1px 0 white/60` top highlight is
/// approximated by a 1px lighter top border on the widget itself, applied by
/// the caller (see shared/widgets card wrappers), not here.
class NutriFlowShadows {
  const NutriFlowShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final tint = brightness == Brightness.dark ? Colors.black : const Color(0xFF2C2720);
    final opacity = brightness == Brightness.dark ? 0.35 : 0.10;
    return [
      BoxShadow(
        color: tint.withValues(alpha: opacity * 0.4),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: tint.withValues(alpha: opacity),
        blurRadius: 30,
        spreadRadius: -16,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static List<BoxShadow> float(Brightness brightness) {
    final tint = brightness == Brightness.dark ? Colors.black : const Color(0xFF2C2720);
    final opacity = brightness == Brightness.dark ? 0.45 : 0.14;
    return [
      BoxShadow(
        color: tint.withValues(alpha: opacity * 0.35),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: tint.withValues(alpha: opacity),
        blurRadius: 48,
        spreadRadius: -20,
        offset: const Offset(0, 18),
      ),
    ];
  }

  /// Reserved for the FAB and other `highlight`-colored surfaces: a shadow
  /// tinted by the highlight color itself rather than the neutral
  /// foreground, so the floating action button visibly glows.
  static List<BoxShadow> highlightGlow(Color highlightColor) {
    return [
      BoxShadow(
        color: highlightColor.withValues(alpha: 0.35),
        blurRadius: 24,
        spreadRadius: -6,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
