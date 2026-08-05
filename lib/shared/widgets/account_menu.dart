import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radii.dart';
import '../../core/theme/shadows.dart';

/// The account control in the dashboard header.
///
/// This replaces `ClerkUserButton`, which is not a button at all: it renders
/// a whole card inline - avatar, name, email, a "Perfil"/"Cerrar sesion"
/// button pair and dividers - styled by Clerk's own theme extension rather
/// than ours. Dropped into a header row it reads as a foreign panel bolted
/// onto the screen, which is exactly what it looked like.
///
/// What stays Clerk's is the part that must be: signing out goes through
/// [ClerkAuthState.signOut] inside `safelyCall`, so the session ends
/// server-side too and any failure reaches the app's [ClerkErrorListener]
/// instead of vanishing.
class AccountAvatarButton extends StatelessWidget {
  const AccountAvatarButton({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    final user = ClerkAuth.userOf(context);
    final name = user?.hasName == true ? user!.name : 'Tu cuenta';

    return Semantics(
      button: true,
      label: 'Cuenta de $name',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: AccountAvatar(imageUrl: user?.imageUrl, name: name, size: size),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final action = await showModalBottomSheet<_AccountAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _AccountSheet(),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _AccountAction.profile:
        context.push('/profile');
      case _AccountAction.signOut:
        await confirmSignOut(context);
    }
  }
}

/// Confirms, then ends the Clerk session. Shared with the profile screen so
/// both entry points behave identically, including the confirmation step -
/// signing out is one tap away from a lot of typing on the logging screen.
Future<void> confirmSignOut(BuildContext context) async {
  final authState = ClerkAuth.of(context, listen: false);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cerrar sesion'),
      content: const Text('Tendras que volver a iniciar sesion para ver tus registros.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          child: const Text('Cerrar sesion'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await authState.safelyCall(context, () => authState.signOut());
}

enum _AccountAction { profile, signOut }

class _AccountSheet extends StatelessWidget {
  const _AccountSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final user = ClerkAuth.userOf(context);
    final name = user?.hasName == true ? user!.name : 'Tu cuenta';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: semantics.card,
            borderRadius: BorderRadius.circular(NutriFlowRadii.card),
            boxShadow: NutriFlowShadows.float(theme.brightness),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: semantics.muted,
                  borderRadius: BorderRadius.circular(NutriFlowRadii.full),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  AccountAvatar(imageUrl: user?.imageUrl, name: name, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.email case final email?) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: semantics.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              _SheetAction(
                icon: LucideIcons.userRound,
                label: 'Ver perfil',
                onTap: () => Navigator.of(context).pop(_AccountAction.profile),
              ),
              _SheetAction(
                icon: LucideIcons.logOut,
                label: 'Cerrar sesion',
                destructive: true,
                onTap: () => Navigator.of(context).pop(_AccountAction.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final color = destructive ? theme.colorScheme.error : semantics.cardForeground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NutriFlowRadii.tile),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round profile picture, falling back to the initial when there is no image
/// or the network one fails. A broken avatar must never take a screen down.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 44,
  });

  final String? imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: semantics.highlight, shape: BoxShape.circle),
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: semantics.highlightForeground,
          fontSize: size * 0.4,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[account] avatar failed to load: $error');
          return fallback;
        },
      ),
    );
  }
}
