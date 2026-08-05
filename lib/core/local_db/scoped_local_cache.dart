import 'local_cache.dart';

/// Binds a [LocalCache] to one signed-in account.
///
/// Row-level security scopes what the app can *fetch*; it does nothing about
/// what is already sitting in SQLite on the device. Without this wrapper the
/// cache keys are global constants ('goal', 'today_meals', ...), so a second
/// person signing in on the same phone and losing connectivity would be
/// served the first person's cached dashboard, weight history, and fasting
/// notes by `cachedFetch`'s offline fallback.
///
/// Two behaviours enforce the boundary:
///
/// * Every key is namespaced by [scope], so one account can never read
///   another's entry - not even by asking for the same logical key.
/// * The first operation after construction deletes everything outside the
///   current namespace, so a previous account's data does not linger on disk
///   once someone else is using the device.
///
/// While signed out ([scope] is null) reads return null and writes are
/// dropped, rather than falling back to unattributed keys: data with no owner
/// is exactly what this class exists to prevent.
class ScopedLocalCache implements LocalCache {
  ScopedLocalCache(this._delegate, this.scope);

  final LocalCache _delegate;

  /// Identifier of the account this cache belongs to (the Clerk user id), or
  /// null while signed out.
  final String? scope;

  Future<void>? _purge;

  String _scoped(String key) => 'u:$scope:$key';

  /// Runs at most once per instance, and a new instance is built for each
  /// signed-in account (see `localCacheProvider`), so switching accounts
  /// purges the previous one exactly once.
  Future<void> _purgeOtherAccounts() => _purge ??= _delegate.clearExcept('u:$scope:');

  @override
  Future<void> putCache(String key, Object? jsonEncodable) async {
    if (scope == null) return;
    await _purgeOtherAccounts();
    await _delegate.putCache(_scoped(key), jsonEncodable);
  }

  @override
  Future<Object?> getCache(String key) async {
    if (scope == null) return null;
    await _purgeOtherAccounts();
    return _delegate.getCache(_scoped(key));
  }

  /// Forwarded verbatim: the prefix is the caller's to choose, and scoping it
  /// again would turn a purge of other accounts into a no-op.
  @override
  Future<void> clearExcept(String keyPrefix) => _delegate.clearExcept(keyPrefix);
}
