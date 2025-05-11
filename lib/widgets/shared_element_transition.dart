import 'package:flutter/material.dart';

class SharedElementTransition extends PageRouteBuilder {
  final Widget page;
  final String tag;
  final Widget sharedElement;

  SharedElementTransition({
    required this.page,
    required this.tag,
    required this.sharedElement,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        FadeTransition(
          opacity: animation,
          child: child,
        ),
        Hero(
          tag: tag,
          child: Material(
            type: MaterialType.transparency,
            child: sharedElement,
          ),
        ),
      ],
    );
  }
}

class SharedElementWidget extends StatelessWidget {
  final String tag;
  final Widget child;
  final VoidCallback? onTap;

  const SharedElementWidget({
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

class SharedElementTransitionBuilder extends StatelessWidget {
  final String tag;
  final Widget child;
  final Widget Function(BuildContext, Animation<double>, Widget) builder;

  const SharedElementTransitionBuilder({
    Key? key,
    required this.tag,
    required this.child,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
} 