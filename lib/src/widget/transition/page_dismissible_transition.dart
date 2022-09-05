part of '../carousel_viewpager.dart';

/// The transition of item fill vacancies animation
class _PageDismissalTransition extends AnimatedWidget {
  /// item index
  final int index;

  /// selected item index
  final int currentIndex;

  /// delete item index
  final int? deletedIndex;

  /// for special case, last item was deleted
  final bool lastItemDeleted;

  /// for special case, last item was deleted
  final bool skipAnimation;

  final bool transformHitTests;

  final Widget child;

  /// total animation process, 0 - 1
  final Animation<double> animation;

  final double besideWidgetScale;

  final Axis scrollDirection;

  final bool reverse;

  final DismissalConfig dismissalConfig;

  /// forward animation will start after dismissal animation finished
  late final Animation<Offset> _fillGapOffsetAnimation;
  late final Animation<double> _fillGapScaleAnimation;

  /// dismissal animations, you can combine several [DismissalType] to own dismissal animation
  final Map<DismissalType, Animation> _dismissalAnimations = {};

  final Size? contentSize;
  late final double radius;
  final Size pageSize;
  late final double pageWidth = pageSize.width;
  late final double pageHeight = pageSize.height;
  late final double contentWidth = contentSize!.width;
  late final double contentHeight = contentSize!.height;

  final VoidCallback? onEnd;

  /// if dismissal type combine [DismissalType.circularHide] and [DismissalType.slideOut]
  /// the center should follow [DismissalType.slideOut] to offset
  final _Offset _currentSlideOutOffset = _Offset();

  /// if dismissal type combine [DismissalType.circularHide], [DismissalType.slideOut] and [DismissalType.scale]
  /// the center should consider [DismissalType.scale] to offset
  final _Scale _currentScale = _Scale();

  _PageDismissalTransition({
    Key? key,
    required this.index,
    required this.currentIndex,
    required this.deletedIndex,
    this.lastItemDeleted = false,
    this.skipAnimation = true,
    required this.animation,
    required this.besideWidgetScale,
    this.transformHitTests = true,
    required this.scrollDirection,
    required this.reverse,
    required this.child,
    required this.dismissalConfig,
    required this.contentSize,
    required this.pageSize,
    this.onEnd,
  }) : super(key: key, listenable: animation) {
    double fillGapStart = dismissalConfig.longestDismissalPercentage +
        dismissalConfig.delayStartFillGapPercentage;
    // fill gap animation
    _fillGapScaleAnimation = Tween<double>(
            begin: index == currentIndex
                ? besideWidgetScale // selected item
                : index < currentIndex
                    ? 1 / besideWidgetScale // left item
                    : besideWidgetScale, // right item
            end: 1)
        .animate(CurvedAnimation(
      curve: Interval(fillGapStart, 1, curve: dismissalConfig.fillGapCurve),
      parent: animation,
    ));
    Offset forwardOffsetBegin;
    if (scrollDirection == Axis.horizontal) {
      forwardOffsetBegin = Offset(reverse || lastItemDeleted ? -1 : 1, 0);
    } else {
      forwardOffsetBegin = Offset(
        0,
        reverse || lastItemDeleted ? -1 : 1,
      );
    }
    _fillGapOffsetAnimation =
        Tween<Offset>(begin: forwardOffsetBegin, end: const Offset(0, 0))
            .animate(CurvedAnimation(
      curve: Interval(fillGapStart, 1, curve: dismissalConfig.fillGapCurve),
      parent: animation,
    ));

    // dismissal animation
    final List<DismissalType> dismissalTypes = dismissalConfig.dismissalTypes;

    for (DismissalType dismissalType in dismissalTypes) {
      double dismissalEnd =
          1 - dismissalConfig.dismissTypePercentage(dismissalType);
      Curve curve = dismissalType.curve;
      late Animation dismissalAnimation;
      if (dismissalType is _DismissalTypeFadeOut) {
        dismissalAnimation =
            Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          curve: Interval(dismissalEnd, 1, curve: curve),
          parent: animation,
        ));
      } else if (dismissalType is _DismissalTypeSlideOut) {
        Offset slideOutOffset;
        switch (dismissalType.slideOutDirection) {
          case SlideDirection.up:
            slideOutOffset = const Offset(0, -1);
            break;
          case SlideDirection.down:
            slideOutOffset = const Offset(0, 1);
            break;
          case SlideDirection.left:
            slideOutOffset = const Offset(-1, 0);
            break;
          case SlideDirection.right:
            slideOutOffset = const Offset(1, 0);
            break;
        }
        dismissalAnimation =
            Tween<Offset>(begin: slideOutOffset, end: Offset.zero)
                .animate(CurvedAnimation(
          curve: Interval(dismissalEnd, 1, curve: curve),
          parent: animation,
        ));
      } else if (dismissalType is _DismissalTypeScaleOut) {
        dismissalAnimation =
            Tween<double>(begin: dismissalType.scaleValue, end: 1)
                .animate(CurvedAnimation(
          curve: Interval(dismissalEnd, 1, curve: curve),
          parent: animation,
        ));
      } else if (dismissalType is _DismissalTypeCircularHide) {
        if (contentSize != null) {
          if (dismissalType.center != null) {
            radius = contentSize!.center(dismissalType.center!).distance;
          } else {
            radius = contentSize!.center(Offset.zero).distance;
          }
        }
        dismissalAnimation =
            Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          curve: Interval(dismissalEnd, 1, curve: curve),
          parent: animation,
        ));
      }
      _dismissalAnimations[dismissalType] = dismissalAnimation;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animation.status == AnimationStatus.completed) {
      // reset _currentSlideOutOffset
      _currentSlideOutOffset.reset();
      // reset _currentScale
      _currentScale.reset();

      onEnd?.call();
    } else if (animation.status == AnimationStatus.forward) {
      if (skipAnimation && index <= currentIndex) return child;

      Offset offset = _fillGapOffsetAnimation.value;
      return FractionalTranslation(
        translation: offset,
        transformHitTests: transformHitTests,
        child: ScaleTransition(
          scale: _fillGapScaleAnimation,
          child: child,
        ),
      );
    } else if (animation.status == AnimationStatus.reverse) {
      if (skipAnimation) {
        return const SizedBox();
      }
      if (deletedIndex != null) {
        // left item of delete item should not present, just keeping old chile
        if (!lastItemDeleted) {
          if (index < deletedIndex!) return child;
        }
        // deleted item start leaving process, fade out and slide out
        if (deletedIndex == index) {
          bool dismissalDone =
              animation.value < 1 - dismissalConfig.longestDismissalPercentage;
          if (dismissalDone) return const SizedBox();
          Widget content = _buildDismissWidget(child);
          return content;
        }
      }
      // right item of delete item, should not present leaving process
      return Opacity(
        opacity: 0,
        child: child,
      );
    }

    return child;
  }

  Widget _buildDismissWidget(Widget child) {
    final List<DismissalType> dismissalTypes = dismissalConfig.dismissalTypes;
    return dismissalTypes.fold(child, (previousChild, dismissalType) {
      if (dismissalType is _DismissalTypeFadeOut) {
        Animation<double> fadeOutAnimation =
            _dismissalAnimations[dismissalType] as Animation<double>;
        double opacity = fadeOutAnimation.value;
        return Opacity(
          opacity: opacity,
          child: previousChild,
        );
      } else if (dismissalType is _DismissalTypeSlideOut) {
        Animation<Offset> slideOutAnimation =
            _dismissalAnimations[dismissalType] as Animation<Offset>;
        Offset offset = slideOutAnimation.value;
        _currentSlideOutOffset.add(offset);
        return FractionalTranslation(
          translation: offset,
          transformHitTests: transformHitTests,
          child: previousChild,
        );
      } else if (dismissalType is _DismissalTypeScaleOut) {
        Animation<double> scaleOutAnimation =
            _dismissalAnimations[dismissalType] as Animation<double>;
        _currentScale.set(scaleOutAnimation.value);
        return ScaleTransition(
          scale: scaleOutAnimation,
          child: previousChild,
        );
      } else if (dismissalType is _DismissalTypeCircularHide) {
        if (contentSize == null) {
          return previousChild;
        }

        Animation<double> circleCollapseAnimation =
            _dismissalAnimations[dismissalType] as Animation<double>;
        double value = circleCollapseAnimation.value;
        Offset center;
        if (dismissalType.center != null) {
          Offset start = Offset(
              (pageWidth - contentWidth) / 2, (pageHeight - contentHeight) / 2);
          center = start + dismissalType.center!;
        } else {
          center = Offset(pageWidth / 2, pageHeight / 2);
        }
        if (_currentSlideOutOffset != Offset.zero) {
          center += Offset(
              pageWidth * _currentSlideOutOffset.dx * _currentScale.scale,
              pageHeight * _currentSlideOutOffset.dy * _currentScale.scale);
        }
        return ClipPath(
          clipper: _CircularClipper(value * radius, center),
          child: previousChild,
        );
      }
      return previousChild;
    });
  }
}

class _CircularClipper extends CustomClipper<Path> {
  const _CircularClipper(this.radius, this.center);

  final double radius;
  final Offset center;

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(radius: radius, center: center));
    return path;
  }

  @override
  bool shouldReclip(_CircularClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}

class _Scale {
  double scale = 1;
  void reset() => scale = 1;
  void set(double scale) => this.scale = scale;
}

class _Offset extends Offset {
  double _dx = 0;
  double _dy = 0;
  _Offset([double dx = 0, double dy = 0])
      : _dx = dx,
        _dy = dy,
        super(dx, dy);

  @override
  double get dx => _dx;

  @override
  double get dy => _dy;

  bool isZero() => _dx == 0 && _dy == 0;

  void reset() {
    _dx = 0;
    _dy = 0;
  }

  void add(Offset offset) {
    double dx = offset.dx;
    double dy = offset.dy;
    if (dx != 0) {
      bool sameSignal = (dx.isNegative && _dx.isNegative) ||
          (!dx.isNegative && !_dx.isNegative);
      if (sameSignal) {
        _dx = dx;
      } else {
        _dx = _dx + dx;
      }
    }
    if (dy != 0) {
      bool sameSignal = (dy.isNegative && _dy.isNegative) ||
          (!dy.isNegative && !_dy.isNegative);
      if (sameSignal) {
        _dy = dy;
      } else {
        _dy = _dy + dy;
      }
    }
  }
}
