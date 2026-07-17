import 'package:flutter/animation.dart';

/// Same bezier as the web (`cubic-bezier(0.23, 1, 0.32, 1)`), so transitions
/// feel identical across clients. Animate transform/opacity only. Callers
/// must still check `MediaQuery.disableAnimationsOf(context)` and skip/shrink
/// motion when true (CLAUDE.md section 5, accessibility).
class NutriFlowMotion {
  const NutriFlowMotion._();

  static const Curve curve = Cubic(0.23, 1, 0.32, 1);

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
