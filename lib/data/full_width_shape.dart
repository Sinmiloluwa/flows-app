import 'package:flutter/material.dart';

class FullWidthTrackShape extends SliderTrackShape {
  const FullWidthTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        bool isEnabled = false,
        bool isDiscrete = false,
        required TextDirection textDirection,
      }) {
    // use default painter logic
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final Paint inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;

    final bool thumbLeft = thumbCenter.dx <= trackRect.center.dx;
    final Rect leftRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final Rect rightRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    context.canvas.drawRect(leftRect, activePaint);
    context.canvas.drawRect(rightRect, inactivePaint);
  }
}
