import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Custom card with shadow and border radius
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final GesureCallback? onTap;
  final Border? border;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingM),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = AppTheme.radiusMedium,
    this.backgroundColor = Colors.white,
    this.boxShadow,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? defaultShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: card,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: card,
    );
  }
}

/// Gradient card
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const GradientCard({
    Key? key,
    required this.child,
    required this.gradient,
    this.padding = const EdgeInsets.all(AppTheme.spacingM),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = AppTheme.radiusMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

typedef GesureCallback = void Function();
