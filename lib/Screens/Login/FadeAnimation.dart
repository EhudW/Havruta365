import 'package:flutter/material.dart';
// https://pub.dev/packages/sa4_migration_kit
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final movieTween = MovieTween()
      ..tween('opacity', Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut)
          .thenTween('translateY', Tween(begin: -30.0, end: 0.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);

    return PlayAnimationBuilder(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: movieTween.duration,
      tween: movieTween,
      child: child,
      builder: (context, Movie animation, child) => Opacity(
        opacity: animation.get("opacity"),
        child: Transform.translate(
            offset: Offset(0, animation.get("translateY")), child: child),
      ),
    );
  }
}
