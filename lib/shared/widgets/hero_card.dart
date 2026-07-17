import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radii.dart';
import '../../core/theme/shadows.dart';

/// The "anchor" surface of a screen (today's summary, the active meal plan).
/// Oversized radius + a soft top highlight border approximating the web's
/// inset shadow (Flutter has no native inset shadow, see shadows.dart).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // `semantics.card`, not `theme.cardColor` - the latter is Material's
        // unset default (doesn't track our dark/light tokens), which is why
        // the hero card previously blended into the page in dark mode
        // instead of reading as a distinct "white-ish" floating surface.
        color: semantics.card,
        borderRadius: BorderRadius.circular(NutriFlowRadii.hero),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
            width: 1,
          ),
        ),
        boxShadow: NutriFlowShadows.float(theme.brightness),
      ),
      child: child,
    );
  }
}
