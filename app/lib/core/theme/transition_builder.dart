import 'package:flutter/material.dart';

class EaseInOutFadePageTransationBuilder extends PageTransitionsBuilder {
  const EaseInOutFadePageTransationBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
      child: child,
    );
  }
}