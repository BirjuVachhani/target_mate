import 'package:flutter/material.dart';

class AnimatedHorizontalProgressBar extends StatefulWidget {
  final Color? backgroundColor;
  final double? height;
  final double value;
  final Curve curve;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Animation<Color?>? valueColor;

  const AnimatedHorizontalProgressBar({
    super.key,
    this.height,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
    this.curve = Curves.easeOut,
    this.duration = const Duration(milliseconds: 500),
    required this.value,
  });

  @override
  State<AnimatedHorizontalProgressBar> createState() =>
      _AnimatedHorizontalProgressBarState();
}

class _AnimatedHorizontalProgressBarState
    extends State<AnimatedHorizontalProgressBar> {
  double initial = 0;

  @override
  void didUpdateWidget(covariant AnimatedHorizontalProgressBar oldWidget) {
    initial = oldWidget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 1,
      child: ClipRRect(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.height ?? 1),
        child: TweenAnimationBuilder<double>(
          curve: widget.curve,
          tween: Tween<double>(begin: initial, end: widget.value),
          duration: widget.duration,
          builder: (context, value, child) => LinearProgressIndicator(
            backgroundColor: widget.backgroundColor,
            valueColor: widget.valueColor ??
                AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
            value: value,
          ),
        ),
      ),
    );
  }
}
