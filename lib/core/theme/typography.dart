import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale for the "Sophisticated Playful" pass. Plus Jakarta Sans per
/// CLAUDE.md section 5 (never the system default). Numbers always get
/// tabular figures so macro/calorie counts don't jitter as they update.
class NutriFlowTypography {
  const NutriFlowTypography._();

  static TextTheme textTheme(Color foreground, Color mutedForeground) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base
        .copyWith(
          // Hero numbers: today's calories, a macro total.
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 40,
            height: 1.05,
            letterSpacing: -0.5,
            color: foreground,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          // Screen title ("Resumen de hoy").
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.3,
            color: foreground,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: foreground,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: foreground,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: foreground,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: foreground,
          ),
          // Overline / eyebrow labels ("PORCION", "PROTEINA").
          labelSmall: base.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.8,
            color: mutedForeground,
          ),
        )
        .apply(bodyColor: foreground, displayColor: foreground);
  }
}
