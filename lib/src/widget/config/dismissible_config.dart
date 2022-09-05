part of '../carousel_viewpager.dart';

class DismissalConfig {
  /// enable page dismissal animation
  final bool enable;

  /// delay, after dismissal and before fill gap, default 0.1s
  final Duration delayStartFillGap;

  /// animation duration of item fill gap, default 0.4s
  final Duration fillGapDuration;

  /// slide out direction of item dismissal animation, default [DismissalType.slideOutUp] combine [DismissalType.fadeOut]
  late final List<DismissalType> dismissalTypes;

  /// The animation curve to use when page filling gap, default [Curves.linear]
  final Curve fillGapCurve;

  DismissalConfig({
    this.enable = true,
    this.delayStartFillGap = const Duration(milliseconds: 100),
    this.fillGapDuration = const Duration(milliseconds: 400),
    List<DismissalType>? dismissalTypes,
    this.fillGapCurve = Curves.linear,
  }) : dismissalTypes = dismissalTypes ??
            [DismissalType.fadeOut(), DismissalType.slideOut()];

  Duration get longestDismissalDuration =>
      dismissalTypes.fold(Duration.zero, (previousValue, element) {
        return element.dismissalDuration > previousValue
            ? element.dismissalDuration
            : previousValue;
      });

  Duration get totalDuration =>
      longestDismissalDuration + delayStartFillGap + fillGapDuration;

  double dismissTypePercentage(DismissalType dismissalType) {
    return dismissalType.dismissalDuration.inMicroseconds /
        totalDuration.inMicroseconds;
  }

  double get longestDismissalPercentage =>
      longestDismissalDuration.inMicroseconds / totalDuration.inMicroseconds;

  double get delayStartFillGapPercentage =>
      delayStartFillGap.inMicroseconds / totalDuration.inMicroseconds;

  double get fillGapPercentage =>
      fillGapDuration.inMicroseconds / totalDuration.inMicroseconds;
}

/// the dismissal animation type
class DismissalType with _$DismissalParam {
  /// dismiss widget by fade out animation
  /// [dismissalDuration] is the animation duration, default 0.5s
  /// default animation [curve] to Curves.linear
  static DismissalType fadeOut({
    Duration dismissalDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
  }) =>
      _DismissalTypeFadeOut(dismissalDuration: dismissalDuration, curve: curve);

  /// dismiss widget by fade out animation
  /// [slideOutDirection] config directions, up, down, left and right, default slide out direction is [SlideDirection.up]
  /// [dismissalDuration] is the animation duration, default 0.5s
  /// default animation [curve] to Curves.linear
  static DismissalType slideOut({
    SlideDirection slideOutDirection = SlideDirection.up,
    Duration dismissalDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
  }) =>
      _DismissalTypeSlideOut(
        slideOutDirection: slideOutDirection,
        dismissalDuration: dismissalDuration,
        curve: curve,
      );

  /// dismiss widget by scale animation
  /// set [scale] for scale animation, default 2
  /// [dismissalDuration] is the animation duration, default 0.5s
  /// default animation [curve] to Curves.linear
  static DismissalType scale({
    double scale = 2,
    Duration dismissalDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
  }) =>
      _DismissalTypeScaleOut(
        scaleValue: scale,
        dismissalDuration: dismissalDuration,
        curve: curve,
      );

  /// dismiss widget by collapsing child with circle clip
  /// base on the the widget created by [DismissibleCarouselViewPager.itemBuilder], set [center] of circle, default to center if [center] is null
  /// [dismissalDuration] is the animation duration, default 0.5s
  /// default animation [curve] to Curves.linear
  static DismissalType circularHide({
    Offset? center,
    Duration dismissalDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
  }) =>
      _DismissalTypeCircularHide(
        dismissalDuration: dismissalDuration,
        curve: curve,
        center: center,
      );
}

class _DismissalTypeFadeOut extends DismissalType {
  _DismissalTypeFadeOut({
    Duration? dismissalDuration,
    Curve curve = Curves.linear,
  }) {
    this.dismissalDuration =
        dismissalDuration ?? const Duration(milliseconds: 500);
    this.curve = curve;
  }
}

class _DismissalTypeSlideOut extends DismissalType {
  final SlideDirection slideOutDirection;

  _DismissalTypeSlideOut({
    required this.slideOutDirection,
    required Duration dismissalDuration,
    required Curve curve,
  }) {
    this.dismissalDuration = dismissalDuration;
    this.curve = curve;
  }
}

class _DismissalTypeScaleOut extends DismissalType {
  final double scaleValue;

  _DismissalTypeScaleOut({
    required this.scaleValue,
    required Duration dismissalDuration,
    required Curve curve,
  }) {
    this.dismissalDuration = dismissalDuration;
    this.curve = curve;
  }
}

class _DismissalTypeCircularHide extends DismissalType {
  final Offset? center;

  _DismissalTypeCircularHide({
    Duration? dismissalDuration,
    Curve curve = Curves.linear,
    this.center,
  }) {
    this.dismissalDuration =
        dismissalDuration ?? const Duration(milliseconds: 500);
    this.curve = curve;
  }
}

mixin _$DismissalParam {
  /// duration of item dismissal animation
  late final Duration dismissalDuration;

  /// The animation curve, default [Curves.linear]
  late final Curve curve;
}

enum SlideDirection {
  /// direction up
  up,

  /// direction down
  down,

  /// direction left
  left,

  /// direction right
  right,
}
