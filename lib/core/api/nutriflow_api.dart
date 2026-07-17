import 'package:dio/dio.dart';

import '../../models/macro_goal.dart';
import '../../models/parse_food_result.dart';

/// Result of a failed call: the REST layer never throws raw [DioException]
/// out to callers, since every Fase 1 endpoint returns a JSON `{ error }`
/// body worth surfacing (CLAUDE.md: never swallow errors, always propagate
/// with context).
class ApiFailure implements Exception {
  const ApiFailure(this.statusCode, this.error);

  final int? statusCode;
  final String error;

  @override
  String toString() => 'ApiFailure($statusCode, $error)';
}

/// Typed wrapper over the Fase 1 REST endpoints in
/// `nutriflow/src/app/api/*`. One method per endpoint, mirroring the exact
/// request/response shapes the route handlers validate with Zod - see each
/// method's doc comment for the schema it must stay in sync with.
class NutriFlowApi {
  const NutriFlowApi(this._dio);

  final Dio _dio;

  /// POST /api/meal-plan/regenerate - no body.
  Future<void> regenerateMealPlan() => _post('/api/meal-plan/regenerate');

  /// POST /api/meal-plan/log-planned - body `{ slot: int }`.
  Future<void> logPlannedMeal({required int slot}) =>
      _post('/api/meal-plan/log-planned', data: {'slot': slot});

  /// POST /api/nlp/parse - body `{ text: string }` (parseFoodInputSchema,
  /// nutriflow/src/lib/validation/nlp.ts). The LLM only extracts/normalizes
  /// entities (name, quantity, unit) and ranks catalog candidates - it never
  /// computes macros (CLAUDE.md §2/§6).
  Future<ParseFoodResult> parseFoodText(String text) async {
    final response = await _post('/api/nlp/parse', data: {'text': text});
    return ParseFoodResult.fromJson(
      (response.data as Map<String, dynamic>)['result'] as Map<String, dynamic>,
    );
  }

  /// POST /api/onboarding/complete - body is the full onboarding payload
  /// (onboardingSchema, nutriflow/src/lib/validation/onboarding.ts):
  /// recordName, goal, method, sex, age, heightCm, weightKg,
  /// targetWeightKg, pace, activityLevel, trainingDays, strengthTraining,
  /// diet, measurementUnits, mealsPerDay, mainMeals, suggestionStyle,
  /// foodSelections (List<String> of catalog food UUIDs), and optional
  /// intermittentFasting/hardest/extraGoal. Left as a raw map since the
  /// onboarding wizard UI (which will assemble this) doesn't exist yet.
  Future<void> completeOnboarding(Map<String, dynamic> payload) =>
      _post('/api/onboarding/complete', data: payload);

  /// POST /api/onboarding/food-selections - body is a BARE JSON array of
  /// catalog food UUIDs, not an object: `["<uuid>", ...]`.
  Future<void> updateFoodSelections(List<String> foodIds) =>
      _post('/api/onboarding/food-selections', data: foodIds);

  /// GET /api/goals - current active macro goal (falls back to a server
  /// default if the user has none yet).
  Future<MacroGoal> getGoal() async {
    final response = await _get('/api/goals');
    return MacroGoal.fromJson((response.data as Map<String, dynamic>)['goal'] as Map<String, dynamic>);
  }

  /// POST /api/goals - body matches `setGoalSchema`: calorieTarget,
  /// proteinTarget, carbsTarget, fatTarget (all required ints).
  Future<void> setGoal(MacroGoal goal) => _post('/api/goals', data: goal.toJson());

  /// POST /api/logging/log-meal - body matches `quickLogSchema`
  /// (nutriflow/src/lib/validation/meal.ts): foodId, grams, mealType, and an
  /// optional source (defaults server-side to 'manual'). The macro snapshot
  /// is computed server-side (`prepareMealItem`/`computeMacros`) - this client
  /// never does that math (CLAUDE.md §2).
  Future<void> logMeal({
    required String foodId,
    required num grams,
    required String mealType,
    String? source,
  }) =>
      _post(
        '/api/logging/log-meal',
        data: {
          'foodId': foodId,
          'grams': grams,
          'mealType': mealType,
          if (source != null) 'source': source,
        },
      );

  Future<Response<dynamic>> _post(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> _get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  ApiFailure _toFailure(DioException e) {
    final body = e.response?.data;
    final error = body is Map<String, dynamic> ? body['error'] as String? : null;
    if (error != null) return ApiFailure(e.response?.statusCode, error);

    final connectivityError = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.connectionError =>
        'no se pudo conectar al servidor',
      DioExceptionType.receiveTimeout || DioExceptionType.sendTimeout => 'el servidor tardo demasiado en responder',
      _ => null,
    };
    return ApiFailure(e.response?.statusCode, connectivityError ?? e.message ?? 'unknown_error');
  }
}
