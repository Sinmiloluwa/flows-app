import 'package:flutter/material.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.child,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.grey,
                Colors.grey,
                Colors.grey,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _shimmerController.value * 2, 0.0),
              end: Alignment(1.0 + _shimmerController.value * 2, 0.0),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Convenience widget for common shimmer patterns
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

// Shimmer for text lines
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: 4.0,
    );
  }
}

// Shimmer for card/image placeholders
class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
