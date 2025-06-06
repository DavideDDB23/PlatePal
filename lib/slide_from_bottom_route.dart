import 'package:flutter/material.dart';

class SlideFromBottomRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFromBottomRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 350), // Adjust duration as needed
          reverseTransitionDuration: const Duration(milliseconds: 300), // Adjust duration for pop
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            // Use a CurvedAnimation for a smoother effect (e.g., Curves.easeInOut)
            final CurvedAnimation curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic, // Experiment with different curves
              reverseCurve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0), // Start from bottom
                end: Offset.zero,            // End at center
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
}