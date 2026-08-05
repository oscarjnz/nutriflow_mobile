import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/scheduler.dart';
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
/// sign-out: it scopes the on-device cache (see [ScopedLocalCache]) and,
/// because Riverpod rebuilds every dependent when this value changes, it
/// also drops the in-memory state of user-scoped providers when the account
/// changes. That cascade is the point: listing the providers to invalidate
/// by hand would silently miss whichever one is added next.
///
/// Reads the id already persisted with the session, so it stays correct with
/// no network - which matters, since its whole job is guarding the cache the
/// app falls back on when offline.
final currentUserIdProvider =
    NotifierProvider<CurrentUserId, String?>(CurrentUserId.new);

class CurrentUserId extends Notifier<String?> {
  /// [ClerkAuthState] is a [ChangeNotifier] that fires on every auth change,
  /// token refreshes included, so this listens and republishes the id.
  ///
  /// Publishing it with `state =` rather than `ref.invalidateSelf()` is
  /// deliberate, and the difference is not cosmetic. `invalidateSelf` only
  /// marks the provider dirty; the recomputation happens later, whenever
  /// something flushes it. On the Galaxy A55 that flush landed inside a
  /// widget build - a route transition toggles `TickerMode`, which makes
  /// `flutter_riverpod` resume its subscriptions and flush mid-build - and
  /// the resulting notification to dependents made Riverpod call `setState`
  /// on the scope while the framework was building. Assigning `state`
  /// applies the change immediately instead, so no dirty value is ever left
  /// pending across a build.
  @override
  String? build() {
    final auth = ref.watch(clerkAuthProvider);
    auth.addListener(_onAuthChanged);
    ref.onDispose(() => auth.removeListener(_onAuthChanged));
    return auth.user?.id;
  }

  void _onAuthChanged() {
    if (!ref.mounted) return;
    final next = ref.read(clerkAuthProvider).user?.id;
    // The frequent no-op notifications (token refreshes) end here: without
    // this guard each one costs a rebuild of the whole user-scoped graph.
    if (next == state) return;

    // Clerk can notify from inside a build - it drives an overlay, and the
    // sign-in flow completes while routes are animating. Mutating provider
    // state then is the same illegal `setState` described above, so wait for
    // the frame to finish.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      state = next;
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted) return;
      final latest = ref.read(clerkAuthProvider).user?.id;
      if (latest != state) state = latest;
    });
  }
}
