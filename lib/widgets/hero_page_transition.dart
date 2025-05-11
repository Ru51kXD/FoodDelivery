import 'package:flutter/material.dart';

class HeroPageTransition extends PageRouteBuilder {
  final Widget page;
  final String heroTag;
  final Widget heroWidget;

  HeroPageTransition({
    required this.page,
    required this.heroTag,
    required this.heroWidget,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: page,
      ),
    );
  }
}

class HeroWidget extends StatelessWidget {
  final String tag;
  final Widget child;
  final VoidCallback? onTap;

  const HeroWidget({
    Key? key,
    required this.tag,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
} 