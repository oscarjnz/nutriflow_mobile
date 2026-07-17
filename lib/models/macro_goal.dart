import 'package:freezed_annotation/freezed_annotation.dart';

part 'macro_goal.freezed.dart';
part 'macro_goal.g.dart';

/// Mirrors `MacroGoal` in `nutriflow/src/repositories/user-goals.repo.ts`.
/// Keep field names/ranges in sync with `setGoalSchema`
/// (`nutriflow/src/lib/validation/goals.ts`) - this is a mechanical mirror,
/// not a place to add client-side validation logic (CLAUDE.md section 2).
@freezed
abstract class MacroGoal with _$MacroGoal {
  const factory MacroGoal({
    required int calorieTarget,
    required int proteinTarget,
    required int carbsTarget,
    required int fatTarget,
  }) = _MacroGoal;

  factory MacroGoal.fromJson(Map<String, dynamic> json) => _$MacroGoalFromJson(json);
}
