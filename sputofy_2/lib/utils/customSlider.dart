import 'package:flutter/material.dart';
import 'package:sputofy_2/utils/palette.dart';

SliderThemeData CustomTheme = SliderThemeData(
  activeTrackColor: accentColor,
  thumbColor: accentColor,
  inactiveTrackColor: secondaryColor,
  overlayColor: secondAccentColor,
  thumbShape: RoundSliderThumbShape(
    enabledThumbRadius: 8.0,
  ),
  overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
  trackShape: CustomTrackShape(),
);

class CustomTrackShape extends RectangularSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
