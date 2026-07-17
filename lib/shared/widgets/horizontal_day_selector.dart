import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/radii.dart';

class DaySelectorItem {
  const DaySelectorItem({required this.label, required this.value, required this.status});

  final String label;
  final String value;
  final String status;
}

/// Horizontal snap-scroll selector (days of the week, meal slots). Inactive
/// items are compact squares; the active item expands into a pill that
/// surfaces its value inline, so scanning the row tells a story instead of
/// requiring a second glance at a separate panel.
class HorizontalDaySelector extends StatelessWidget {
  const HorizontalDaySelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<DaySelectorItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final active = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: NutriFlowMotion.standard,
              curve: NutriFlowMotion.curve,
              width: active ? 160 : 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: active ? semantics.invertedSurface : semantics.card,
                borderRadius: BorderRadius.circular(active ? NutriFlowRadii.full : NutriFlowRadii.tile),
                border: active
                    ? null
                    : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: active
                  ? Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: semantics.highlight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            item.value,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: semantics.highlightForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.status,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: semantics.onInvertedSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(item.label, style: theme.textTheme.labelSmall),
                    ),
            ),
          );
        },
      ),
    );
  }
}
