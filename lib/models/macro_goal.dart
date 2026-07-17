/// Mirrors `MacroGoal` in `nutriflow/src/repositories/user-goals.repo.ts`.
/// Keep field names/ranges in sync with `setGoalSchema`
/// (`nutriflow/src/lib/validation/goals.ts`) - this is a mechanical mirror,
/// not a place to add client-side validation logic (CLAUDE.md section 2).
///
/// Hand-written rather than `@freezed` for now: the installed build_runner
/// (2.5.4, capped there transitively) crashes on this Flutter/Dart SDK
/// (analyzer can't parse dot-shorthand syntax the framework sources use -
/// see CLAUDE.md 2026-07-17 bitacora) before it can generate anything.
/// Switch back to freezed once that toolchain gap is resolved.
class MacroGoal {
  const MacroGoal({
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
  });

  final int calorieTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;

  factory MacroGoal.fromJson(Map<String, dynamic> json) => MacroGoal(
        calorieTarget: json['calorieTarget'] as int,
        proteinTarget: json['proteinTarget'] as int,
        carbsTarget: json['carbsTarget'] as int,
        fatTarget: json['fatTarget'] as int,
      );

  Map<String, dynamic> toJson() => {
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
      };
}
