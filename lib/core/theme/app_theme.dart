import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'radii.dart';
import 'typography.dart';

class NutriFlowTheme {
  const NutriFlowTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? NutriFlowColors.darkBackground : NutriFlowColors.lightBackground;
    final foreground = isDark ? NutriFlowColors.darkForeground : NutriFlowColors.lightForeground;
    final card = isDark ? NutriFlowColors.darkCard : NutriFlowColors.lightCard;
    final cardForeground = isDark
        ? NutriFlowColors.darkCardForeground
        : NutriFlowColors.lightCardForeground;
    final primary = isDark ? NutriFlowColors.darkPrimary : NutriFlowColors.lightPrimary;
    final primaryForeground = isDark
        ? NutriFlowColors.darkPrimaryForeground
        : NutriFlowColors.lightPrimaryForeground;
    final muted = isDark ? NutriFlowColors.darkMuted : NutriFlowColors.lightMuted;
    final mutedForeground = isDark
        ? NutriFlowColors.darkMutedForeground
        : NutriFlowColors.lightMutedForeground;
    final border = isDark ? NutriFlowColors.darkBorder : NutriFlowColors.lightBorder;
    final destructive = isDark
        ? NutriFlowColors.darkDestructive
        : NutriFlowColors.lightDestructive;
    final destructiveForeground = isDark
        ? NutriFlowColors.darkDestructiveForeground
        : NutriFlowColors.lightDestructiveForeground;

    final semantics = isDark ? NutriFlowSemanticColors.dark : NutriFlowSemanticColors.light;
    final textTheme = NutriFlowTypography.textTheme(foreground, mutedForeground);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: primaryForeground,
      secondary: semantics.highlight,
      onSecondary: semantics.highlightForeground,
      error: destructive,
      onError: destructiveForeground,
      surface: card,
      onSurface: cardForeground,
      outline: border,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      extensions: [
        semantics,
        // Ports the ClerkAuthentication widget's furniture (sign-in/sign-up
        // panel from features/auth/login_screen.dart) onto the same tokens
        // as the rest of the app, so the login screen doesn't look like an
        // unstyled third-party drop-in.
        ClerkThemeExtension(
          colors: ClerkThemeColors(
            background: card,
            altBackground: muted,
            borderSide: border,
            text: foreground,
            icon: mutedForeground,
            lightweightText: mutedForeground,
            error: destructive,
            accent: primary,
          ),
        ),
      ],
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NutriFlowRadii.card),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: semantics.highlight,
          foregroundColor: semantics.highlightForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutriFlowRadii.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutriFlowRadii.control),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriFlowRadii.control),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: border,
      splashFactory: NoSplash.splashFactory,
    );
  }
}
