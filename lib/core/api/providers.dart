import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'nutriflow_api.dart';

/// Set once in main() after ClerkAuthState is created, before runApp -
/// every other provider that needs auth or the API client reads through
/// this rather than each constructing its own ClerkAuthState.
final clerkAuthProvider = Provider<ClerkAuthState>((ref) {
  throw UnimplementedError('clerkAuthProvider must be overridden in main()');
});

final nutriFlowApiProvider = Provider<NutriFlowApi>((ref) {
  final clerkAuth = ref.watch(clerkAuthProvider);
  return NutriFlowApi(buildApiClient(clerkAuth));
});
