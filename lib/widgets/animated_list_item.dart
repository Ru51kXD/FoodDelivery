import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class AnimatedListBuilder extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const AnimatedListBuilder({
    Key? key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          duration: duration,
          curve: curve,
          child: children[index],
        );
      },
    );
  }
}

class AnimatedGridBuilder extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const AnimatedGridBuilder({
    Key? key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          duration: duration,
          curve: curve,
          child: children[index],
        );
      },
    );
  }
} 