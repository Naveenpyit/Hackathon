import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Elegant custom AppBar with gradient background and premium design
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showGradient;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.showGradient = false,
    this.backgroundColor,
    this.titleColor = AppTheme.textPrimary,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: showGradient
            ? AppTheme.primaryGradient
            : null,
        color: showGradient ? null : (backgroundColor ?? AppTheme.surfaceColor),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingM,
          ),
          child: Row(
            children: [
              // Back Button
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (showGradient ? Colors.white : Colors.grey)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: showGradient ? Colors.white : titleColor,
                        size: 24,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              const SizedBox(width: AppTheme.spacingM),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: showGradient ? Colors.white : titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              // Actions
              if (actions != null) ...[
                ...actions!,
              ] else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
