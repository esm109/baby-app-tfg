import 'package:flutter/material.dart';

Route MaterialPageRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),

    pageBuilder: (
      context,
      animation,
      secondaryAnimation,
    ) =>
        page,

    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      const begin = Offset(0.08, 0);
      const end = Offset.zero;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );

      final fadeAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(animation);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}