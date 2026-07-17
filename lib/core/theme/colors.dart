import 'package:flutter/material.dart';

/// Color tokens ported 1:1 from `nutriflow/src/app/globals.css` (source of
/// truth, section 5 of CLAUDE.md). Values converted from the original HSL
/// triplets to RGB hex - do not hand-tune a hex value without updating the
/// HSL source in the web repo first, the two must stay in sync.
class NutriFlowColors {
  const NutriFlowColors._();

  // --- Light ---
  static const lightBackground = Color(0xFFFDFDFC);
  static const lightForeground = Color(0xFF2C2720);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardForeground = Color(0xFF2C2720);
  static const lightPrimary = Color(0xFF668B4B);
  static const lightPrimaryForeground = Color(0xFFFDFDFC);
  static const lightMuted = Color(0xFFF5F3EF);
  static const lightMutedForeground = Color(0xFF766D60);
  static const lightBorder = Color(0xFFE6E2DB);
  static const lightRing = Color(0xFF668B4B);
  static const lightDestructive = Color(0xFFDD442C);
  static const lightDestructiveForeground = Color(0xFFFDFDFC);

  static const lightMacroProtein = Color(0xFF668B4B);
  static const lightMacroCarbs = Color(0xFFF2960D);
  static const lightMacroFat = Color(0xFFE16A37);

  // --- Dark ---
  static const darkBackground = Color(0xFF141310);
  static const darkForeground = Color(0xFFF3F1ED);
  static const darkCard = Color(0xFF1F1D19);
  static const darkCardForeground = Color(0xFFF3F1ED);
  static const darkPrimary = Color(0xFF7DB356);
  static const darkPrimaryForeground = Color(0xFF141310);
  static const darkMuted = Color(0xFF2F2D28);
  static const darkMutedForeground = Color(0xFFAAA292);
  static const darkBorder = Color(0xFF322F2A);
  static const darkRing = Color(0xFF7DB356);
  static const darkDestructive = Color(0xFFC6432F);
  static const darkDestructiveForeground = Color(0xFFF3F1ED);

  static const darkMacroProtein = Color(0xFF7DB356);
  static const darkMacroCarbs = Color(0xFFEEA02B);
  static const darkMacroFat = Color(0xFFDF7649);
}

/// Semantic role mapping for the mobile "Sophisticated Playful" pass.
///
/// The web app today uses `primary` (sage) for every button indiscriminately,
/// which is part of why it reads as generic. Mobile splits the accent role in
/// two, mirroring how the reference design reserves its vibrant red for
/// high-impact actions only:
///   - [highlight] (mapped to the existing `destructive` token) drives the
///     FAB, the primary "log a meal" CTA, and critical alerts - the handful
///     of moments that should pull the eye first.
///   - [primary] (sage) stays for everything else: secondary buttons, active
///     nav/tab state, focus rings, links.
/// This is additive, not a token rename - `destructive` still means
/// destructive in error/delete contexts. No change to the web repo's tokens.
class NutriFlowSemanticColors extends ThemeExtension<NutriFlowSemanticColors> {
  const NutriFlowSemanticColors({
    required this.highlight,
    required this.highlightForeground,
    required this.macroProtein,
    required this.macroCarbs,
    required this.macroFat,
    required this.card,
    required this.cardForeground,
    required this.muted,
    required this.mutedForeground,
    required this.invertedSurface,
    required this.onInvertedSurface,
    required this.onInvertedSurfaceMuted,
  });

  final Color highlight;
  final Color highlightForeground;
  final Color macroProtein;
  final Color macroCarbs;
  final Color macroFat;
  final Color card;
  final Color cardForeground;
  final Color muted;
  final Color mutedForeground;

  /// The floating nav bar and the active day-selector pill deliberately swap
  /// polarity against the page (a light bar on a dark page, a dark bar on a
  /// light page) so they read as a distinct floating layer. Content drawn on
  /// them must use these tokens - NOT [mutedForeground]/[cardForeground],
  /// which assume same-polarity placement (e.g. text on a normal card) and
  /// produce near-invisible low-contrast icons when used on an inverted
  /// surface (this was a real bug: inactive nav icons used
  /// [mutedForeground], which in dark mode is a *light* gray landing on the
  /// bar's *light* cream background).
  final Color invertedSurface;
  final Color onInvertedSurface;
  final Color onInvertedSurfaceMuted;

  static const light = NutriFlowSemanticColors(
    highlight: NutriFlowColors.lightDestructive,
    highlightForeground: NutriFlowColors.lightDestructiveForeground,
    macroProtein: NutriFlowColors.lightMacroProtein,
    macroCarbs: NutriFlowColors.lightMacroCarbs,
    macroFat: NutriFlowColors.lightMacroFat,
    card: NutriFlowColors.lightCard,
    cardForeground: NutriFlowColors.lightCardForeground,
    muted: NutriFlowColors.lightMuted,
    mutedForeground: NutriFlowColors.lightMutedForeground,
    invertedSurface: NutriFlowColors.lightForeground,
    onInvertedSurface: NutriFlowColors.lightBackground,
    onInvertedSurfaceMuted: NutriFlowColors.darkMutedForeground,
  );

  static const dark = NutriFlowSemanticColors(
    highlight: NutriFlowColors.darkDestructive,
    highlightForeground: NutriFlowColors.darkDestructiveForeground,
    macroProtein: NutriFlowColors.darkMacroProtein,
    macroCarbs: NutriFlowColors.darkMacroCarbs,
    macroFat: NutriFlowColors.darkMacroFat,
    card: NutriFlowColors.darkCard,
    cardForeground: NutriFlowColors.darkCardForeground,
    muted: NutriFlowColors.darkMuted,
    mutedForeground: NutriFlowColors.darkMutedForeground,
    invertedSurface: NutriFlowColors.darkForeground,
    onInvertedSurface: NutriFlowColors.darkBackground,
    onInvertedSurfaceMuted: NutriFlowColors.lightMutedForeground,
  );

  @override
  NutriFlowSemanticColors copyWith({
    Color? highlight,
    Color? highlightForeground,
    Color? macroProtein,
    Color? macroCarbs,
    Color? macroFat,
    Color? card,
    Color? cardForeground,
    Color? muted,
    Color? mutedForeground,
    Color? invertedSurface,
    Color? onInvertedSurface,
    Color? onInvertedSurfaceMuted,
  }) {
    return NutriFlowSemanticColors(
      highlight: highlight ?? this.highlight,
      highlightForeground: highlightForeground ?? this.highlightForeground,
      macroProtein: macroProtein ?? this.macroProtein,
      macroCarbs: macroCarbs ?? this.macroCarbs,
      macroFat: macroFat ?? this.macroFat,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      invertedSurface: invertedSurface ?? this.invertedSurface,
      onInvertedSurface: onInvertedSurface ?? this.onInvertedSurface,
      onInvertedSurfaceMuted: onInvertedSurfaceMuted ?? this.onInvertedSurfaceMuted,
    );
  }

  @override
  NutriFlowSemanticColors lerp(ThemeExtension<NutriFlowSemanticColors>? other, double t) {
    if (other is! NutriFlowSemanticColors) return this;
    return NutriFlowSemanticColors(
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightForeground: Color.lerp(highlightForeground, other.highlightForeground, t)!,
      macroProtein: Color.lerp(macroProtein, other.macroProtein, t)!,
      macroCarbs: Color.lerp(macroCarbs, other.macroCarbs, t)!,
      macroFat: Color.lerp(macroFat, other.macroFat, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      invertedSurface: Color.lerp(invertedSurface, other.invertedSurface, t)!,
      onInvertedSurface: Color.lerp(onInvertedSurface, other.onInvertedSurface, t)!,
      onInvertedSurfaceMuted: Color.lerp(onInvertedSurfaceMuted, other.onInvertedSurfaceMuted, t)!,
    );
  }
}
