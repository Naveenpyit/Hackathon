import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Reusable branded app logo.
///
/// Renders the Smart App logo as a rounded-square gradient badge with
/// the white lightning bolt (matches the launcher icon).
///
/// Use this anywhere in the app instead of raw `Icons.bolt_rounded`
/// for brand consistency.
class SmartAppLogo extends StatelessWidget {
  final double size;

  /// Adds a soft glow shadow under the logo. Default: true.
  final bool withShadow;

  /// Overrides the default radius ratio. Default is ~22% of size
  /// (matches launcher icon squircle).
  final double? radiusRatio;

  const SmartAppLogo({
    super.key,
    this.size = 80,
    this.withShadow = true,
    this.radiusRatio,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * (radiusRatio ?? 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(50),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/logo/Media.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
