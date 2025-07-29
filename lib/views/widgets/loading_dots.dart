import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;
  final Duration duration;

  const LoadingDots({
    Key? key,
    this.color = Colors.white,
    this.size = 8.0,
    this.dotCount = 3,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration * widget.dotCount,
      vsync: this,
    )..repeat();

    _animations = List.generate(widget.dotCount, (i) {
      final start = i / widget.dotCount;
      final end = (i + 1) / widget.dotCount;
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Opacity(
            opacity: _animations[i].value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}