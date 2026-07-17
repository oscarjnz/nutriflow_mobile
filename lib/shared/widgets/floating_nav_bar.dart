import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/radii.dart';
import '../../core/theme/shadows.dart';

/// Fixed bottom pill nav with a floating center FAB that sits half-outside
/// the bar. The FAB uses `highlight` (not `primary`) so the app's one
/// reserved-for-impact color lands on the anchor action (log a meal) - see
/// the role-split rationale in core/theme/colors.dart.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
    required this.fabIcon,
  });

  final List<IconData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;
  final IconData fabIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    final leftItems = items.sublist(0, (items.length / 2).ceil());
    final rightItems = items.sublist((items.length / 2).ceil());

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SizedBox(
        height: 64 + 24,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: semantics.invertedSurface,
                borderRadius: BorderRadius.circular(NutriFlowRadii.full),
                boxShadow: NutriFlowShadows.float(theme.brightness),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ..._buildTabs(leftItems, 0, semantics),
                  const SizedBox(width: 56),
                  ..._buildTabs(rightItems, leftItems.length, semantics),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onFabTap,
                child: AnimatedContainer(
                  duration: NutriFlowMotion.fast,
                  curve: NutriFlowMotion.curve,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: semantics.highlight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 4,
                    ),
                    boxShadow: NutriFlowShadows.highlightGlow(semantics.highlight),
                  ),
                  child: Icon(fabIcon, color: semantics.highlightForeground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabs(
    List<IconData> tabs,
    int offset,
    NutriFlowSemanticColors semantics,
  ) {
    return List.generate(tabs.length, (i) {
      final index = offset + i;
      final active = index == currentIndex;
      return IconButton(
        iconSize: 22,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: () => onTap(index),
        icon: Icon(
          tabs[i],
          color: active ? semantics.onInvertedSurface : semantics.onInvertedSurfaceMuted,
        ),
      );
    });
  }
}
