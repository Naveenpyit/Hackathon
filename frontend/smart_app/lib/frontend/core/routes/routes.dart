import 'package:flutter/material.dart';

/// Custom fade transition for page routes
class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Custom slide transition for page routes
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.rightToLeft,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin = Offset.zero;
      
      switch (direction) {
        case SlideDirection.leftToRight:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.rightToLeft:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.topToBottom:
          begin = const Offset(0.0, -1.0);
          break;
        case SlideDirection.bottomToTop:
          begin = const Offset(0.0, 1.0);
          break;
      }
      
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Custom scale transition for page routes
class ScalePageRoute extends PageRouteBuilder {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: Curves.easeInOutCubic),
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

/// Slide direction enum for SlidePageRoute
enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Named page route generator for use with Navigator.pushNamed
class RouteGenerator {
  static const Duration transitionDuration = Duration(milliseconds: 400);

  /// Generate routes with consistent naming pattern
  static PageRoute<dynamic> generateRoute(
    RouteSettings settings, {
    required Widget Function(RouteSettings) pageBuilder,
    PageRouteTransition transition = PageRouteTransition.slide,
  }) {
    switch (transition) {
      case PageRouteTransition.fade:
        return FadePageRoute(
          page: pageBuilder(settings),
        );
      case PageRouteTransition.scale:
        return ScalePageRoute(
          page: pageBuilder(settings),
        );
      case PageRouteTransition.slide:
      default:
        return SlidePageRoute(
          page: pageBuilder(settings),
          direction: SlideDirection.rightToLeft,
        );
    }
  }
}

/// Page route transition types
enum PageRouteTransition {
  fade,
  slide,
  scale,
}
