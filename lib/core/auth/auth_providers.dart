import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set once in main() after ClerkAuthState is created, before runApp -
/// every other provider that needs auth or the API client reads through
/// this rather than each constructing its own ClerkAuthState.
final clerkAuthProvider = Provider<ClerkAuthState>((ref) {
  throw UnimplementedError('clerkAuthProvider must be overridden in main()');
});

/// The signed-in Clerk user's id, or null while signed out.
///
/// This is the app's session identity for anything that must not outlive a
/// sign-out: it scopes the on-device cache (see
/// [ScopedLocalCache]) and, because Riverpod rebuilds every dependent when
/// this value changes, it also drops the in-memory state of user-scoped
/// providers when the account changes. That cascade is the point: listing
/// the providers to invalidate by hand would silently miss whichever one is
/// added next.
///
/// [ClerkAuthState] is a [ChangeNotifier] that fires on every auth change
/// (token refreshes included), so this listens and recomputes. Riverpod only
/// notifies dependents when the resulting id actually differs, so the
/// frequent no-op notifications cost nothing downstream.
///
/// Reads the id already persisted with the session, so it stays correct with
/// no network - which matters, since its whole job is guarding the cache the
/// app falls back on when offline.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(clerkAuthProvider);
  void onAuthChanged() => ref.invalidateSelf();
  auth.addListener(onAuthChanged);
  ref.onDispose(() => auth.removeListener(onAuthChanged));
  return auth.user?.id;
});
