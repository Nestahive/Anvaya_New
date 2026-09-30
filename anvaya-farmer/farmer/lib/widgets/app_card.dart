import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable dark rounded card with subtle green border and optional glow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasGlow;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.hasGlow = false,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: borderColor ?? AppColors.borderGreen,
      width: 1.0,
    );

    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      border: border,
      boxShadow: hasGlow
          ? [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      return Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
