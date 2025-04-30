import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final bool isLoading;
  final Widget? child;

  const ShimmerLoading({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8,
    this.isLoading = true,
    this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          clipBehavior: widget.borderRadius > 0 ? Clip.antiAlias : Clip.none,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: const [
                  Color(0xFFEBEBF4),
                  Color(0xFFF5F5F5),
                  Color(0xFFEBEBF4),
                ],
                stops: const [0.1, 0.3, 0.4],
                begin: Alignment(_animation.value, -1),
                end: Alignment(-_animation.value, 1),
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            child: widget.child ?? Container(color: Colors.grey[300]),
          ),
        );
      },
    );
  }
} 