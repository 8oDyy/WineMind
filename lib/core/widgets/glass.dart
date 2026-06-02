import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Boîte à outils « liquid glass » iOS : surfaces translucides floutées
/// (`BackdropFilter`), coins arrondis et bordure fine, déclinées en conteneur
/// de base, dialog, bottom sheet et SnackBar. À utiliser partout à la place des
/// `AlertDialog` / `SnackBar` / `showModalBottomSheet` bruts pour un rendu iOS
/// cohérent.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Teinte de base posée sur le flou (translucide). Par défaut un blanc laiteux
  /// proche du « regular material » iOS.
  final Color tint;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 18,
    this.borderRadius = 24,
    this.padding,
    this.tint = const Color(0xCCFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Dégradé subtil pour l'effet « verre » (haut un peu plus clair).
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint,
                tint.withValues(alpha: (tint.a * 0.82).clamp(0.0, 1.0)),
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}

/// Une action de [GlassDialog] : libellé + callback. `isDestructive` colore en
/// rouge (suppression), `isDefault` met en gras (action principale iOS).
class GlassDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Dialog de confirmation en liquid glass, calqué sur l'`UIAlertController`
/// iOS (titre, message, actions empilées séparées par de fins traits).
class GlassDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<GlassDialogAction> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: GlassContainer(
              borderRadius: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: AppColors.textPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _GlassDivider(),
                  _GlassActionsRow(actions: actions),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rangée d'actions : côte à côte si 2 actions (style iOS), empilées sinon.
class _GlassActionsRow extends StatelessWidget {
  final List<GlassDialogAction> actions;

  const _GlassActionsRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.length == 2) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _GlassActionButton(action: actions[0])),
            const _GlassDivider(vertical: true),
            Expanded(child: _GlassActionButton(action: actions[1])),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const _GlassDivider(),
          _GlassActionButton(action: actions[i]),
        ],
      ],
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final GlassDialogAction action;

  const _GlassActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive ? Colors.red : AppColors.primaryWine;
    return TextButton(
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(),
        // Pas de splash Material : feedback iOS via highlight discret.
        splashFactory: NoSplash.splashFactory,
        foregroundColor: color,
      ),
      child: Text(
        action.label,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight:
              action.isDefault ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

/// Fin trait séparateur translucide (horizontal par défaut, vertical si demandé).
class _GlassDivider extends StatelessWidget {
  final bool vertical;

  const _GlassDivider({this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.4);
    return vertical
        ? Container(width: 0.6, color: color)
        : Container(height: 0.6, color: color);
  }
}

/// Bottom sheet en liquid glass : enveloppe [showModalBottomSheet] avec un fond
/// transparent et une surface glass à coins hauts arrondis + poignée.
class GlassBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: isScrollControlled,
      builder: (_) => GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.only(top: 10),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée iOS.
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Construit un [SnackBar] en liquid glass clair (flottant, translucide blanc
/// frosté, cohérent avec la nav bar et les dialogs). `isError` passe l'accent
/// (icône + libellé d'action) en rouge ; le fond reste clair et lisible.
/// Optionnellement une action (libellé + callback).
SnackBar glassSnackBar(
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final accent = isError ? Colors.red.shade700 : AppColors.primaryWine;
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: duration,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.all(16),
    content: GlassContainer(
      blur: 18,
      borderRadius: 18,
      // Verre clair (blanc translucide) — plus de dalle sombre.
      tint: const Color(0xF2FFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
